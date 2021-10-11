import 'package:flutter/material.dart';
import 'package:tau_sound/public/tau_node.dart';
import 'package:tau_sound/public/tau_player.dart';

typedef Fn = void Function();

class PlayFromAsset extends StatefulWidget {
  const PlayFromAsset({Key? key}) : super(key: key);

  @override
  _PlayFromAssetState createState() => _PlayFromAssetState();
}

class _PlayFromAssetState extends State<PlayFromAsset> {
  TauPlayer? _mPlayer = TauPlayer();
  bool _mPlayerIsInited = false;

  Future<void> open() async {
    await _mPlayer!.open(
        from: InputAssetNode('assets/samples/sample.mp3'),
        to: OutputDeviceNode.speaker());
    setState(() {
      _mPlayerIsInited = true;
    });
  }

  @override
  void initState() {
    super.initState();
    open();
  }

  @override
  void dispose() {
    stopPlayer();
    _mPlayer!.close();
    _mPlayer = null;
    super.dispose();
  }

  void play() async {
    await _mPlayer!.play(
      whenFinished: () {
        setState(() {});
      },
    );
    setState(() {});
  }

  Future<void> stopPlayer() async {
    if (_mPlayer != null) {
      await _mPlayer!.stop();
    }
  }

  Fn? getPlaybackFn() {
    if (!_mPlayerIsInited) {
      return null;
    }
    return _mPlayer!.isStopped
        ? play
        : () {
            stopPlayer().then((value) => setState(() {}));
          };
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: getPlaybackFn(),
                //color: Colors.white,
                //disabledColor: Colors.grey,
                child: Text(_mPlayer!.isPlaying ? 'Stop' : 'Play'),
              ),
              SizedBox(
                width: 20,
              ),
              Text(_mPlayer!.isPlaying
                  ? 'Playing the asset file'
                  : 'Player is stopped'),
            ]),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Play from Asset'),
      ),
      body: makeBody(),
    );
  }
}
