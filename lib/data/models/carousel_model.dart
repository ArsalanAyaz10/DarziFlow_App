class CarouselModel {
  final String id;
  final String imageUrl;
  final String publicId;
  final String title;
  final String? description;
  final String? link;
  final bool isActive;
  final int priority;

  CarouselModel({
    required this.id,
    required this.imageUrl,
    required this.publicId,
    required this.title,
    this.description,
    this.link,
    this.isActive = true,
    this.priority = 0,
  });

  factory CarouselModel.fromJson(Map<String, dynamic> json) {
    return CarouselModel(
      id: json['_id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      publicId: json['publicId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      link: json['link'],
      isActive: json['isActive'] ?? true,
      priority: json['priority'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imageUrl': imageUrl,
      'publicId': publicId,
      'title': title,
      'description': description,
      'link': link,
      'isActive': isActive,
      'priority': priority,
    };
  }
}
