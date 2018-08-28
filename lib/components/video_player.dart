// import 'package:video_player/video_player.dart';
// import 'package:flutter/material.dart';

// class PeggVideoPlayer extends StatefulWidget {
//   PeggVideoPlayer(String gif) : this._gif = gif;
//   final String _gif;
//   @override
//   _PeggVideoPlayerState createState() => _PeggVideoPlayerState();
// }

// class _PeggVideoPlayerState extends State<PeggVideoPlayer> {
//   VideoPlayerController _controller;
//   bool _isPlaying = true;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget._gif)
//       ..addListener(() {
//         final bool isPlaying = _controller.value.isPlaying;
//         if (isPlaying != _isPlaying) {
//           setState(() {
//             _isPlaying = isPlaying;
//           });
//         }
//       })
//       ..initialize().then((_) {
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});
//       });
//       _controller.play();
//       _controller.setLooping(true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//         child: Padding(
//             padding: EdgeInsets.all(10.0),
//             child: Center(
//               child: _controller.value.initialized
//                   ? AspectRatio(
//                       aspectRatio: _controller.value.aspectRatio,
//                       child: VideoPlayer(_controller),
//                     )
//                   : Container(),
//             )),
//         onTap:
//             _controller.value.isPlaying ? _controller.pause : _controller.play);
//   }
// }
