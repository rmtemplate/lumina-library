class LibraryNearbyLibraryData {
  const LibraryNearbyLibraryData({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.distanceText,
    required this.durationText,
    required this.scheduleText,
    required this.openStatusText,
    required this.isOpen,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String distanceText;
  final String durationText;
  final String scheduleText;
  final String openStatusText;
  final bool isOpen;
  final double? latitude;
  final double? longitude;
}
