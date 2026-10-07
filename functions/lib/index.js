"use strict";
/**
 * =============================================================
 *  Family Root - Cloud Functions
 * =============================================================
 *  1) createMemberAccount       -> admin ສ້າງບັນຊີ member (ບໍ່ຕ້ອງອອກຈາກລະບົບ)
 *  2) deleteUserAccount         -> ລຶບບັນຊີອອກຈາກ Firebase Auth ຢ່າງສົມບູນ
 *  3) onChatMessageCreated      -> ສົ່ງແຈ້ງເຕືອນ (FCM) ໄປຫາຜູ້ຮັບເມື່ອມີຂໍ້ຄວາມໃໝ່
 *  4) syncFamilyMemberCount     -> ຮັກສາຈຳນວນສະມາຊິກໃຫ້ກົງກັບຄວາມຈິງ
 *  5) onMemberWriteSyncGeneration -> ຄຳນວນລຸ້ນ (generation) ອັດຕະໂນມັດ
 * =============================================================
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMemberWriteSyncGeneration = exports.syncFamilyMemberCount = exports.onChatMessageCreated = exports.deleteUserAccount = exports.createMemberAccount = void 0;
const app_1 = require("firebase-admin/app");
const auth_1 = require("firebase-admin/auth");
const firestore_1 = require("firebase-admin/firestore");
const messaging_1 = require("firebase-admin/messaging");
const https_1 = require("firebase-functions/v2/https");
const firestore_2 = require("firebase-functions/v2/firestore");
const firebase_functions_1 = require("firebase-functions");
(0, app_1.initializeApp)();
const db = (0, firestore_1.getFirestore)();
const auth = (0, auth_1.getAuth)();
const ALLOWED_ROLES = ["admin", "member"];
/**
 * ສ້າງບັນຊີສະມາຊິກໂດຍ admin ຂອງຄອບຄົວ
 * ໃຊ້ Admin SDK ເພື່ອບໍ່ໃຫ້ session ຂອງ admin ຖືກປ່ຽນແທນ
 */
exports.createMemberAccount = (0, https_1.onCall)({ region: "asia-southeast1", cors: true }, async (request) => {
    const callerUid = request.auth?.uid;
    if (!callerUid) {
        throw new https_1.HttpsError("unauthenticated", "ຕ້ອງເຂົ້າລະບົບກ່ອນ");
    }
    const callerDoc = await db.collection("users").doc(callerUid).get();
    const caller = callerDoc.data();
    if (!caller || caller.role !== "admin") {
        throw new https_1.HttpsError("permission-denied", "ສະເພາະ Admin ຈຶ່ງສ້າງບັນຊີໄດ້");
    }
    const { email, password, displayName, role, familyId, phone, whatsapp, avatarUrl, birthDate, gender, } = request.data ?? {};
    if (!email || !password || !displayName) {
        throw new https_1.HttpsError("invalid-argument", "ຂາດອີແມວ, ລະຫັດຜ່ານ ຫຼື ຊື່");
    }
    if (typeof password !== "string" || password.length < 6) {
        throw new https_1.HttpsError("invalid-argument", "ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ");
    }
    if (role && !ALLOWED_ROLES.includes(role)) {
        throw new https_1.HttpsError("invalid-argument", "role ບໍ່ຖືກຕ້ອງ");
    }
    if (familyId && caller.familyId !== familyId) {
        throw new https_1.HttpsError("permission-denied", "ຕ້ອງເປັນສະມາຊິກຄອບຄົວດຽວກັນ");
    }
    const userRecord = await auth.createUser({
        email,
        password,
        displayName,
        photoURL: avatarUrl || undefined,
        disabled: false,
    });
    await db
        .collection("users")
        .doc(userRecord.uid)
        .set({
        uid: userRecord.uid,
        displayName,
        email,
        phone: phone ?? null,
        whatsapp: whatsapp ?? null,
        avatarUrl: avatarUrl ?? null,
        role: role ?? "member",
        familyId: familyId ?? caller.familyId ?? null,
        providers: ["password"],
        isActive: true,
        birthDate: birthDate ?? null,
        gender: gender ?? null,
        createdAt: firestore_1.FieldValue.serverTimestamp(),
        updatedAt: firestore_1.FieldValue.serverTimestamp(),
    });
    if (familyId) {
        await db
            .collection("families")
            .doc(familyId)
            .collection("activity")
            .add({
            userId: callerUid,
            action: "ສ້າງບັນຊີສະມາຊິກ",
            detail: `${displayName} (${role ?? "member"})`,
            createdAt: firestore_1.FieldValue.serverTimestamp(),
        });
    }
    firebase_functions_1.logger.info(`Admin ${callerUid} ສ້າງບັນຊີ ${userRecord.uid}`);
    return { uid: userRecord.uid };
});
/**
 * ລຶບບັນຊີຜູ້ໃຊ້ອອກຈາກ Firebase Auth (admin ເທົ່ານັ້ນ)
 */
exports.deleteUserAccount = (0, https_1.onCall)({ region: "asia-southeast1", cors: true }, async (request) => {
    const callerUid = request.auth?.uid;
    if (!callerUid)
        throw new https_1.HttpsError("unauthenticated", "ຕ້ອງເຂົ້າລະບົບກ່ອນ");
    const caller = (await db.collection("users").doc(callerUid).get()).data();
    if (!caller || caller.role !== "admin") {
        throw new https_1.HttpsError("permission-denied", "ສະເພາະ Admin ຈຶ່ງລຶບບັນຊີໄດ້");
    }
    const { uid } = request.data ?? {};
    if (!uid)
        throw new https_1.HttpsError("invalid-argument", "ຕ້ອງສົ່ງ uid");
    if (uid === callerUid) {
        throw new https_1.HttpsError("failed-precondition", "ບໍ່ສາມາດລຶບບັນຊີຕົນເອງໄດ້");
    }
    const target = (await db.collection("users").doc(uid).get()).data();
    if (!target ||
        (caller.familyId &&
            target.familyId &&
            caller.familyId !== target.familyId)) {
        throw new https_1.HttpsError("permission-denied", "ບໍ່ສາມາດລຶບບັນຊີຄອບຄົວອື່ນໄດ້");
    }
    try {
        await auth.deleteUser(uid);
    }
    catch (error) {
        firebase_functions_1.logger.warn(`ລຶບ user ໃນ Auth ບໍ່ສຳເລັດ: ${error.message}`);
    }
    await db.collection("users").doc(uid).delete();
    return { success: true };
});
/**
 * ເມື່ອມີຂໍ້ຄວາມໃໝ່ -> ສົ່ງແຈ້ງເຕືອນ (FCM) ໄປຫາຜູ້ຮັບ
 * ໝາຍເຫດ: ບໍ່ອະນຸຍາດໃຫ້ລຶບຂໍ້ຄວາມ - ປະຫວັດຈະຖືກເກັບຮັກສາໄວ້ຕະຫຼອດ
 */
exports.onChatMessageCreated = (0, firestore_2.onDocumentCreated)({
    document: "families/{familyId}/chats/{roomId}/messages/{messageId}",
    region: "asia-southeast1",
}, async (event) => {
    const snapshot = event.data;
    if (!snapshot)
        return;
    const message = snapshot.data();
    const { familyId, roomId } = event.params;
    const senderId = message.senderId;
    const roomSnap = await db
        .collection("families")
        .doc(familyId)
        .collection("chats")
        .doc(roomId)
        .get();
    const participants = roomSnap.data()?.participants ?? [];
    const receiverUid = participants.find((uid) => uid !== senderId);
    if (!receiverUid)
        return;
    const receiverSnap = await db.collection("users").doc(receiverUid).get();
    const token = receiverSnap.data()?.fcmToken;
    if (!token) {
        firebase_functions_1.logger.info(`ຜູ້ຮັບ ${receiverUid} ຍັງບໍ່ມີ FCM token`);
        return;
    }
    const body = message.type === "image" ? "📷 ສົ່ງຮູບພາບ" : String(message.text ?? "");
    try {
        await (0, messaging_1.getMessaging)().send({
            token,
            notification: {
                title: String(message.senderName ?? "ຂໍ້ຄວາມໃໝ່"),
                body: body.substring(0, 120),
            },
            data: { type: "chat", familyId, roomId, senderId },
            android: {
                priority: "high",
                notification: { channelId: "family_root_channel" },
            },
            apns: { payload: { aps: { sound: "default", badge: 1 } } },
        });
    }
    catch (error) {
        firebase_functions_1.logger.error("ສົ່ງແຈ້ງເຕືອນບໍ່ສຳເລັດ", error);
    }
});
/**
 * ຮັກສາຈຳນວນສະມາຊິກຂອງຄອບຄົວໃຫ້ກົງກັບຄວາມຈິງ
 */
exports.syncFamilyMemberCount = (0, firestore_2.onDocumentCreated)({
    document: "families/{familyId}/members/{memberId}",
    region: "asia-southeast1",
}, async (event) => {
    const { familyId } = event.params;
    const membersSnap = await db
        .collection("families")
        .doc(familyId)
        .collection("members")
        .count()
        .get();
    await db
        .collection("families")
        .doc(familyId)
        .set({
        memberCount: membersSnap.data().count,
        updatedAt: firestore_1.FieldValue.serverTimestamp(),
    }, { merge: true });
});
/**
 * ຄຳນວນລຸ້ນຂອງລູກອັດຕະໂນມັດ (ລູກ = ລຸ້ນພໍ່ແມ່ + 1)
 */
exports.onMemberWriteSyncGeneration = (0, firestore_2.onDocumentCreated)({
    document: "families/{familyId}/members/{memberId}",
    region: "asia-southeast1",
}, async (event) => {
    const member = event.data?.data();
    if (!member)
        return;
    const parents = [member.fatherId, member.motherId].filter(Boolean);
    if (parents.length === 0)
        return;
    const { familyId, memberId } = event.params;
    const parentSnaps = await Promise.all(parents.map((id) => db
        .collection("families")
        .doc(familyId)
        .collection("members")
        .doc(id)
        .get()));
    const generations = parentSnaps
        .map((snap) => snap.data()?.generation)
        .filter((g) => typeof g === "number");
    if (generations.length === 0)
        return;
    const expected = Math.max(...generations) + 1;
    if (member.generation !== expected) {
        await db
            .collection("families")
            .doc(familyId)
            .collection("members")
            .doc(memberId)
            .set({ generation: expected, updatedAt: firestore_1.FieldValue.serverTimestamp() }, { merge: true });
    }
});
//# sourceMappingURL=index.js.map