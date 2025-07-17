// lib/app/constants/asset_paths.dart
class AssetPaths {
  // Device Icons
  static const String lightBulb = 'assets/light-bulb.png';
  static const String light = 'assets/light.png';
  static const String chandelier = 'assets/chandlier.png';
  static const String rgb = 'assets/rgb.png';
  static const String ledStrip = 'assets/led-strip.png';
  static const String fan = 'assets/fan.png';
  static const String tableFan = 'assets/table_fan.png';
  static const String coolingFan = 'assets/cooling-fan.png';
  static const String blinds = 'assets/blinds.png';
  static const String powerSocket = 'assets/power-socket.png';
  static const String room = 'assets/room.png';

  // App Assets
  static const String logo = 'assets/logo.png';
  static const String airConditioner = 'assets/air-conditioner.png';
  static const String geyser = 'assets/geyser.png';
  static const String refrigerator = 'assets/refrigerator.png';
  static const String washingMachine = 'assets/washing-machine.png';
  static const String food = 'assets/food.png';

  // Room Icons
  static const String livingRoom = 'assets/icons/rooms/living_room.png';
  static const String bedroom = 'assets/icons/rooms/bedroom.png';
  static const String kitchen = 'assets/icons/rooms/kitchen.png';
  static const String bathroom = 'assets/icons/rooms/bathroom.png';
  static const String office = 'assets/icons/rooms/office.png';
  static const String diningRoom = 'assets/icons/rooms/dining_room.png';
  static const String garage = 'assets/icons/rooms/garage.png';
  static const String garden = 'assets/icons/rooms/garden.png';
  static const String balcony = 'assets/icons/rooms/balcony.png';
  static const String guestRoom = 'assets/icons/rooms/guest_room.png';
  static const String laundry = 'assets/icons/rooms/laundry.png';
  static const String storage = 'assets/icons/rooms/storage.png';

  // Scene Icons
  static const String movieScene = 'assets/icons/scenes/movie.png';
  static const String partyScene = 'assets/icons/scenes/party.png';
  static const String sleepScene = 'assets/icons/scenes/sleep.png';
  static const String workScene = 'assets/icons/scenes/work.png';
  static const String relaxScene = 'assets/icons/scenes/relax.png';
  static const String morningScene = 'assets/icons/scenes/morning.png';
  static const String dinnerScene = 'assets/icons/scenes/dinner.png';
  static const String readingScene = 'assets/icons/scenes/reading.png';
  static const String awayScene = 'assets/icons/scenes/away.png';
  static const String customScene = 'assets/icons/scenes/custom.png';

  // Device Type Icons
  static const String tvIcon = 'assets/icons/devices/tv.png';
  static const String speakerIcon = 'assets/icons/devices/speaker.png';

  // Fonts
  static const String poppinsRegular = 'assets/fonts/Poppins-Regular.ttf';
  static const String poppinsMedium = 'assets/fonts/Poppins-Medium.ttf';
  static const String poppinsSemiBold = 'assets/fonts/Poppins-SemiBold.ttf';
  static const String poppinsBold = 'assets/fonts/Poppins-Bold.ttf';

  // Animations (if needed)
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String errorAnimation = 'assets/animations/error.json';

  // Fallback icons
  static const String deviceUnknown = 'assets/device-unknown.png';
  static const String roomUnknown = 'assets/room-unknown.png';

  // Get icon by device type
  static String getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'on/off':
        return lightBulb;
      case 'dimmable light':
        return light;
      case 'rgb':
        return rgb;
      case 'fan':
        return fan;
      case 'curtain':
        return blinds;
      case 'ir hub':
        return powerSocket;
      default:
        return lightBulb;
    }
  }

  // Get room icon by room type
  static String getRoomIcon(String roomType) {
    switch (roomType.toLowerCase()) {
      case 'living room':
        return livingRoom;
      case 'bedroom':
        return bedroom;
      case 'kitchen':
        return kitchen;
      case 'bathroom':
        return bathroom;
      case 'office':
        return office;
      case 'dining room':
        return diningRoom;
      case 'garage':
        return garage;
      case 'garden':
        return garden;
      case 'balcony':
        return balcony;
      case 'guest room':
        return guestRoom;
      case 'laundry':
        return laundry;
      case 'storage':
        return storage;
      default:
        return room;
    }
  }
}
