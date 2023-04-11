import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_shaders/flutter_shaders.dart';

import 'shader_painter.dart';

class HandleNullImage extends StatefulWidget {
  final Image? image;
  final Widget Function(Image) builder;

  const HandleNullImage({Key? key, required this.image, required this.builder})
      : super(key: key);

  @override
  State<HandleNullImage> createState() => _HandleNullImageState();
}

class _HandleNullImageState extends State<HandleNullImage> {
  @override
  Widget build(BuildContext context) {
    return handleNullImage(widget.image, widget.builder);
  }

  Widget handleNullImage(Image? image, Widget Function(Image) builder) =>
      image == null
          ? const Center(child: CircularProgressIndicator())
          : builder(image);
}

class HandlePairNullImage extends StatefulWidget {
  final Image? image;
  final Image? image2;
  final Widget Function(Image, Image) builder;

  const HandlePairNullImage(
      {Key? key,
      required this.image,
      required this.image2,
      required this.builder})
      : super(key: key);

  @override
  State<HandlePairNullImage> createState() => _HandlePairNullImageState();
}

class _HandlePairNullImageState extends State<HandlePairNullImage> {
  @override
  Widget build(BuildContext context) {
    return handleNullImage(widget.image, widget.image2, widget.builder);
  }

  Widget handleNullImage(
      Image? image, Image? image2, Widget Function(Image, Image) builder) {
    return (image == null || image2 == null)
        ? const Center(child: CircularProgressIndicator())
        : builder(image, image2);
  }
}

extension Helpers on Image {
  Size get size => Size(width.toDouble(), height.toDouble());
}

//================================================
//        pixelate shader builder
//================================================
ShaderBuilder pixelateBuilder({
  required Image image,
  required double numCell,
}) =>
    ShaderBuilder(
      assetKey: 'shaders/pointillism.frag',
      (context, shader, child) {
        shader
          ..setFloat(0, image.width.toDouble())
          ..setFloat(1, image.height.toDouble())
          ..setFloat(2, numCell)
          ..setImageSampler(0, image);

        return CustomPaint(
          size: image.size,
          painter: ShaderPainter(shader),
        );
      },
    );
//================================================

//================================================
//        blur transition shader builder
//================================================
ShaderBuilder blurTransitionBuilder({
  required Image image,
  required Image image2,
  required double deltaTime,
}) =>
    ShaderBuilder(
      assetKey: 'shaders/zoom_blur.frag',
      (context, shader, child) {
        shader
          ..setFloat(0, image.width.toDouble())
          ..setFloat(1, image.height.toDouble())
          ..setFloat(2, deltaTime.toDouble())
          ..setImageSampler(0, image)
          ..setImageSampler(1, image2);

        return CustomPaint(
          size: image.size,
          painter: ShaderPainter(shader),
        );
      },
    );
//================================================

//================================================
//        Wave transition shader buider
//================================================
ShaderBuilder curlTransitionBuilder({
  required Image image,
  required Image image2,
  required double deltaTime,
}) =>
    ShaderBuilder(
      assetKey: 'shaders/waved_transition.frag',
      (context, shader, child) {
        shader
          ..setFloat(0, image.width.toDouble())
          ..setFloat(1, image.height.toDouble())
          ..setFloat(2, deltaTime.toDouble())
          ..setImageSampler(0, image)
          ..setImageSampler(1, image2);

        return CustomPaint(
          size: image.size,
          painter: ShaderPainter(shader),
        );
      },
    );
//================================================
