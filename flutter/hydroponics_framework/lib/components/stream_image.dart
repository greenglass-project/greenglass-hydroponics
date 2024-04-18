import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../microservices/microservice_service.dart';

class StreamImage extends StatefulWidget {
  final String topic;
  final double opacity;

  const StreamImage({required this.topic, this.opacity = 1, super.key});

  @override
  State<StatefulWidget> createState() => _StreamImageState();
}

class _StreamImageState extends State<StreamImage>{

  final ms = MicroserviceService.ms;
  var logger = Logger();

  //Image? image;
  Widget? image;

  @override
  void initState() {
    logger.d("Sending request to ${widget.topic}");
    ms.requestDataNoParameters(widget.topic, (r) {
      if (mounted) {
        setState(() => image = _getImage(r));
      }
    }, (c,m) {} );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(image == null) {
      return Container();
    } else {
      return image!;
    }
  }

  Widget _getImage(Uint8List image)  {
    logger.d("Image size = ${image.length}");
    return Image.memory(image, opacity: AlwaysStoppedAnimation(widget.opacity));
    //return Image.memory(image, fit: BoxFit.contain);

    /*PngDecoder png = PngDecoder();
    JpegDecoder jpg = JpegDecoder();
    if(png.isValidFile(image) || jpg.isValidFile(image)) {
      logger.d("image is PNG or JPEG");
      return Img.Image.memory(image, fit: BoxFit.contain);
    } else {
      logger.d("Image is SVG");
      return SvgPicture.memory(image, fit: BoxFit.contain);
    }*/
  }
}