import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Helpers/colors.dart';
import '../Models/dataModel.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MyRadio _selectedRadio;
  Color _seletcedColor;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _loading = false;
  List<MyRadio> radios;
  @override
  void initState() {
    super.initState();
    setupAlan();
    _fetchData();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  setupAlan() {
    AlanVoice.addButton(
        "b6ab2494580f948b960acf87886a50922e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
  }

  _fetchData() async {
    setState(() {
      _loading = true;
    });
    var radData = await rootBundle.loadString('assets/RadioData.json');
    radios = MyRadioList.fromJson(radData).radios;
    print(radios);
    setState(() {
      _loading = false;
    });
  }

  _playingRadio(String url) async {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: _loading == false
          ? Stack(
              children: [
                VxAnimatedBox()
                    .size(context.screenWidth, context.screenHeight)
                    .withGradient(
                      LinearGradient(
                        colors: [
                          AiColors.primaryColor2,
                          _seletcedColor ?? AiColors.primaryColor1,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                    .make(),
                AppBar(
                  title: "Org Radio".text.xl4.bold.white.make().shimmer(
                      primaryColor: Vx.purple300, secondaryColor: Colors.white),
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  centerTitle: true,
                ).h(100.0).p16(),
                radios != null
                    ? VxSwiper.builder(
                        itemCount: radios.length,
                        enlargeCenterPage: true,
                        onPageChanged: (index) {
                          final color = radios[index].color;
                          _seletcedColor = Color(int.tryParse(color));
                          setState(() {});
                        },
                        aspectRatio: 1.0,
                        itemBuilder: (context, i) {
                          return VxBox(
                                  child: ZStack([
                            Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: VxBox(
                                      child: radios[i]
                                          .category
                                          .text
                                          .uppercase
                                          .white
                                          .make()
                                          .px16())
                                  .height(40)
                                  .black
                                  .alignCenter
                                  .withRounded(value: 10.0)
                                  .make(),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: VStack(
                                [
                                  radios[i].name.text.xl3.white.bold.make(),
                                  5.heightBox,
                                  radios[i]
                                      .tagline
                                      .text
                                      .sm
                                      .white
                                      .semiBold
                                      .make()
                                ],
                                crossAlignment: CrossAxisAlignment.center,
                              ),
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: [
                                  Icon(
                                    CupertinoIcons.play_circle,
                                    color: Colors.white,
                                  ),
                                  10.heightBox,
                                  "Double Tap to Play".text.gray300.make()
                                ].vStack())
                          ]))
                              .clip(Clip.antiAlias)
                              .bgImage(
                                DecorationImage(
                                  image: _loading == false
                                      ? NetworkImage(radios[i].image)
                                      : AssetImage('assets/intro1.gif'),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.3),
                                      BlendMode.darken),
                                ),
                              )
                              .border(color: Colors.black, width: 5.0)
                              .withRounded(value: 60.0)
                              .make()
                              .onInkDoubleTap(() {
                            _playingRadio(radios[i].url);
                          }).p16();
                        }).centered()
                    : Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      ),
                Align(
                        alignment: Alignment.bottomCenter,
                        child: [
                          if (_isPlaying)
                            "Playing Now -${_selectedRadio.name} FM"
                                .text
                                .makeCentered(),
                          Icon(
                            _isPlaying
                                ? CupertinoIcons.stop_circle
                                : CupertinoIcons.play_circle,
                            color: Colors.white,
                            size: 50.0,
                          ).onInkTap(() {
                            if (_isPlaying) {
                              _audioPlayer.stop();
                            } else {
                              _playingRadio(_selectedRadio.url);
                            }
                          })
                        ].vStack())
                    .pOnly(bottom: context.percentHeight * 12)
              ],
              fit: StackFit.expand,
              clipBehavior: Clip.antiAlias,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
