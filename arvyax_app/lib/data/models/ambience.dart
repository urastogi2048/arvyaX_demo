class Ambience {
  final String id;
  final String title;
  final String tag;           
  final int duration;          // in seconds
  final String description;
  final String image;         
  final String audio;          
  final List<String> sensoryTags;  

  Ambience({
    required this.id,
    required this.title,
    required this.tag,
    required this.duration,
    required this.description,
    required this.image,
    required this.audio,
    required this.sensoryTags,
  });
  factory Ambience.fromJson(Map<String, dynamic> json) {
    return Ambience(
      id: json['id'] as String,
      title: json['title'] as String,
      tag: json['tag'] as String,
      duration: json['duration'] as int,
      description: json['description'] as String,
      image: json['image'] as String,
      audio: json['audio'] as String,
      sensoryTags: List<String>.from(json['sensoryTags'] as List),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tag': tag,
      'duration': duration,
      'description': description,
      'image': image,
      'audio': audio,
      'sensoryTags': sensoryTags,
    };
  }
}