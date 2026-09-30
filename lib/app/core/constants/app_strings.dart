/// ຂໍ້ຄວາມທັງໝົດຂອງແອັບ (ພາສາລາວ)
class AppStrings {
  AppStrings._();

  static const String appName = 'Family Root';
  static const String appTagline = 'ຮາກເຮົາ ຮາກໃຈ ຮາກຄອບຄົວ';

  // ---- Tabs ----
  static const String tabHome = 'ໜ້າຫຼັກ';
  static const String tabTree = 'ຜັງຄອບຄົວ';
  static const String tabMembers = 'ສະມາຊິກ';
  static const String tabChat = 'ສົນທະນາ';
  static const String tabProfile = 'ໂປຣໄຟລ໌';

  // ---- Auth ----
  static const String login = 'ເຂົ້າລະບົບ';
  static const String loginSubtitle = 'ຍິນດີຕ້ອນຮັບກັບຄືນ ສູ່ຄອບຄົວຂອງທ່ານ';
  static const String continueWithGoogle = 'ສືບຕໍ່ດ້ວຍ Google';
  static const String continueWithFacebook = 'ສືບຕໍ່ດ້ວຍ Facebook';
  static const String continueWithApple = 'ສືບຕໍ່ດ້ວຍ Apple';
  static const String orLoginWithEmail = 'ຫຼື ເຂົ້າລະບົບດ້ວຍອີແມວ ແລະ ລະຫັດ';
  static const String email = 'ອີແມວ';
  static const String password = 'ລະຫັດຜ່ານ';
  static const String forgotPassword = 'ລືມລະຫັດຜ່ານ?';
  static const String memberOnlyNote =
      'ສະມາຊິກບໍ່ສາມາດລົງທະບຽນໄດ້ ກະລຸນາຕິດຕໍ່ Admin ';
  static const String signOut = 'ອອກຈາກລະບົບ';
  static const String signOutConfirm = 'ທ່ານຕ້ອງການອອກຈາກລະບົບແທ້ບໍ?';

  // ---- Family setup ----
  static const String setupTitle = 'ສ້າງຄອບຄົວຂອງທ່ານ';
  static const String setupSubtitle =
      'ກະລຸນາປ້ອນນາມສະກຸນ ແລະ ລາຍລະອຽດ ເພື່ອເລີ່ມຕົ້ນສ້າງຜັງໄມ້ຄອບຄົວ';
  static const String surname = 'ນາມສະກຸນ';
  static const String surnameHint = 'ຕົວຢ່າງ: ວົງສະຫວັນ';
  static const String familyName = 'ຊື່ຄອບຄົວ';
  static const String familyDescription = 'ລາຍລະອຽດຄອບຄົວ';
  static const String descriptionHint = 'ຕົວຢ່າງ: ຄອບຄົວຢູ່ນະຄອນຫຼວງວຽງຈັນ...';
  static const String province = 'ແຂວງ / ທີ່ຕັ້ງ';
  static const String createFamily = 'ສ້າງຄອບຄົວ';
  static const String surnameRequired = 'ກະລຸນາປ້ອນນາມສະກຸນ';

  // ---- Home ----
  static const String greetingMorning = 'ສະບາຍດີຕອນເຊົ້າ';
  static const String greetingAfternoon = 'ສະບາຍດີຕອນບ່າຍ';
  static const String greetingEvening = 'ສະບາຍດີຕອນແລງ';
  static const String totalMembers = 'ຂໍ້ມູນທັງໝົດ';
  static const String under18 = 'ອາຍຸຕຳກວ່າ 18 ປີ';
  static const String male = 'ຊາຍ';
  static const String female = 'ຍິງ';
  static const String deceased = 'ເສຍຊີວິດ';
  static const String alive = 'ຍັງມີຊີວິດ';
  static const String generationChart = 'ຈຳນວນສະມາຊິກໃນແຕ່ລະລຸ້ນ';
  static const String overview = 'ພາບລວມຂອງຄອບຄົວ';
  static const String quickActions = 'ການຈັດການໄວ';
  static const String addMember = 'ເພີ່ມສະມາຊິກ';
  static const String createAccount = 'ສ້າງບັນຊີ member';

  // ---- Family tree ----
  static const String familyTree = 'ຜັງໄມ້ຄອບຄົວ';
  static const String searchMember = 'ຄົ້ນຫາສະມາຊິກ';
  static const String addNode = 'ເພີ່ມສະມາຊິກໃນຜັງ';
  static const String editNode = 'ແກ້ໄຂຂໍ້ມູນ';
  static const String deleteNode = 'ລຶບສະມາຊິກ';
  static const String deleteNodeConfirm =
      'ທ່ານຕ້ອງການລຶບສະມາຊິກນີ້ອອກຈາກຜັງແທ້ບໍ?';
  static const String exportPdf = 'Export ຜັງເປັນ PDF';
  static const String exportImage = 'ບັນທຶກຮູບຜັງ';
  static const String generation = 'ລຸ້ນທີ';
  static const String father = 'ພໍ່';
  static const String mother = 'ແມ່';
  static const String spouse = 'ຜົວ / ເມຍ';
  static const String children = 'ລູກ';
  static const String siblings = 'ອ້າຍ / ເອື້ອຍ / ນ້ອງ';
  static const String relationships = 'ຄວາມສຳພັນ';
  static const String readOnlyBanner = 'ທ່ານກຳລັງເບິ່ງຜັງໃນໂໝດອ່ານເທົ່ານັ້ນ';

  // ---- Members ----
  static const String members = 'ສະມາຊິກ';
  static const String memberDetail = 'ລາຍລະອຽດສະມາຊິກ';
  static const String addAccount = 'ເພີ່ມບັນຊີສະມາຊິກ';
  static const String editAccount = 'ແກ້ໄຂບັນຊີສະມາຊິກ';
  static const String search = 'ຄົ້ນຫາ...';
  static const String fullName = 'ຊື່';
  static const String phone = 'ເບີໂທ';
  static const String whatsapp = 'ເບີ WhatsApp';
  static const String role = 'ສິດການໃຊ້ງານ (Role)';
  static const String roleAdmin = 'Admin (ຜູ້ດູແລຄອບຄົວ)';
  static const String roleMember = 'Member (ສະມາຊິກຄອບຄົວ)';
  static const String noMembers = 'ຍັງບໍ່ມີສະມາຊິກ';
  static const String noMembersDesc =
      'Admin ສາມາດເພີ່ມບັນຊີສະມາຊິກໄດ້ຈາກປຸ່ມດ້ານລຸ່ມ';
  static const String chatNow = 'ແຊັດຫາ';
  static const String call = 'ໂທ';
  static const String accountInfo = 'ຂໍ້ມູນບັນຊີ';
  static const String personInfo = 'ຂໍ້ມູນບຸກຄົນໃນຜັງ';

  // ---- Chat ----
  static const String chat = 'ສົນທະນາ';
  static const String chatList = 'ລາຍການສົນທະນາ';
  static const String noConversation = 'ຍັງບໍ່ມີການສົນທະນາ';
  static const String noConversationDesc = 'ເລືອກສະມາຊິກ ເພື່ອເລີ່ມສົນທະນາ';
  static const String typeMessage = 'ພິມຂໍ້ຄວາມ...';
  static const String send = 'ສົ່ງ';
  static const String allMembers = 'ສະມາຊິກທັງໝົດ';
  static const String unread = 'ຂໍ້ຄວາມໃໝ່';
  static const String today = 'ມື້ນີ້';
  static const String yesterday = 'ມື້ວານນີ້';
  static const String cannotDeleteMessage = 'ບໍ່ສາມາດລຶບຂໍ້ຄວາມໄດ້';

  // ---- Profile ----
  static const String profile = 'ໂປຣໄຟລ໌';
  static const String editProfile = 'ແກ້ໄຂໂປຣໄຟລ໌';
  static const String loginConnections = 'ການເຊື່ອມຕໍ່ການເຂົ້າລະບົບ';
  static const String familyInfo = 'ຂໍ້ມູນຄອບຄົວ';
  static const String changePhoto = 'ປ່ຽນຮູບພາບ';
  static const String save = 'ບັນທຶກ';
  static const String cancel = 'ຍົກເລີກ';
  static const String update = 'ອັບເດດ';
  static const String delete = 'ລຶບ';
  static const String confirm = 'ຢືນຢັນ';
  static const String seeDetail = 'ເບິ່ງລາຍລະອຽດ';
  static const String settings = 'ຕັ້ງຄ່າ';
  static const String language = 'ພາສາ';
  static const String darkMode = 'ໂໝດມືດ';
  static const String notifications = 'ການແຈ້ງເຕືອນ';
  static const String about = 'ກ່ຽວກັບແອັບ';
  static const String version = 'ເວີຊັນ';

  // ---- Common ----
  static const String loading = 'ກຳລັງໂຫຼດ...';
  static const String retry = 'ລອງໃໝ່';
  static const String error = 'ເກີດຂໍ້ຜິດພາດ';
  static const String success = 'ສຳເລັດ';
  static const String noData = 'ບໍ່ມີຂໍ້ມູນ';
  static const String noInternet = 'ບໍ່ມີການເຊື່ອມຕໍ່ອິນເຕີເນັດ';
  static const String offlineQueued = 'ຂໍ້ມູນຈະຖືກສົ່ງເມື່ອມີເນັດ';
}
