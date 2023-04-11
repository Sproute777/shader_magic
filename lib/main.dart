import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'generated/assets.dart';
import 'shaders_widgets/shader_extension.dart';

void main() => runApp(const MaterialApp(home: AnimView()));

class AnimView extends StatefulWidget {
  final List<String> assets;

  const AnimView(
      {Key? key,
      this.assets = const <String>[
        Assets.assetsNumber1,
        Assets.assetsNumber2,
        Assets.assetsNumber3,
        Assets.assetsNumber4,
        Assets.assetsNumber5,
        Assets.assetsNumber6,
        Assets.assetsNumber7,
        Assets.assetsNumber8,
      ]})
      : super(key: key);

  @override
  State<AnimView> createState() => AnimViewState();
}

class AnimViewState extends State<AnimView>
    with SingleTickerProviderStateMixin {
  ui.Image? _image;
  ui.Image? _image2;

  late final ValueNotifier<int> _firstNotifier;
  late final ValueNotifier<int> _secondNotifier;

  late final AnimationController _animController;
  late final CurvedAnimation _curvedAnim;

  late List<String> _imgAssets;

  @override
  void initState() {
    super.initState();
    _firstNotifier = ValueNotifier<int>(0);
    _secondNotifier = ValueNotifier<int>(1);
    _imgAssets = widget.assets;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
      lowerBound: 3.0,
      upperBound: 9.2,
    );
    _animController.addStatusListener(_onAnimationStatus);
    _curvedAnim = CurvedAnimation(parent: _animController, curve: Curves.ease);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFirstImage();
    _loadSecondImage();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _animController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HandlePairNullImage(
      image: _image,
      image2: _image2,
      builder: (image, image2) => AnimatedBuilder(
        animation: _curvedAnim,
        builder: (context, _) {
          final deltaTime = _animController.value.toDouble();
          return SizedBox(
            child: RepaintBoundary(
              child: FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.cover,
                child: blurTransitionBuilder(
                  image: image,
                  image2: image2,
                  deltaTime: deltaTime,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _loadFirstImage() {
    _image = null;
    final assetStr = _imgAssets[_firstNotifier.value];
    Image.asset(assetStr)
        .image
        .resolve(createLocalImageConfiguration(context))
        .addListener(ImageStreamListener((info, _) {
      setState(() {
        _image = info.image;
      });
    }));
  }

  _loadSecondImage() {
    _image2 = null;
    final assetStr = _imgAssets[_secondNotifier.value];
    Image.asset(assetStr)
        .image
        .resolve(createLocalImageConfiguration(context))
        .addListener(ImageStreamListener((info, _) {
      setState(() {
        _image2 = info.image;
      });
    }));
  }

  void _onAnimationStatus(status) {
    if (status == AnimationStatus.completed) {
      _firstNotifier.value =
          (_firstNotifier.value + 2) % (_imgAssets.length - 1);
      _loadSecondImage();
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          return _animController.reverse();
        }
      });
      return;
    }

    if (status == AnimationStatus.dismissed) {
      _secondNotifier.value =
          (_secondNotifier.value + 2) % (_imgAssets.length - 1);
      _loadFirstImage();
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          return _animController.forward();
        }
      });
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    _animController.dispose();
  }
}
