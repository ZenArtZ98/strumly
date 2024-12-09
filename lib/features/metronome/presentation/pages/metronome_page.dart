import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({Key? key}) : super(key: key);

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> with TickerProviderStateMixin {
  int bpm = 120;
  Timer? timer;
  late AudioPlayer _audioPlayer;
  late AnimationController _pendulumAnimationController;
  late AnimationController _circleAnimationController;
  bool isRunning = false;
  bool showPendulum = true; // Переключатель между маятником и пульсирующим кругом

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _loadAudio();

    // Анимация маятника
    _pendulumAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (60000 / bpm).round()),
    );

    // Анимация пульсирующего круга
    _circleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
  }

  Future<void> _loadAudio() async {
    try {
      await _audioPlayer.setAsset('assets/sounds/Perc_MetronomeQuartz_hi.wav');
    } catch (e) {
      print("Ошибка загрузки звука: $e");
    }
  }

  void _toggleMetronome() {
    if (isRunning) {
      _stopMetronome();
    } else {
      _startMetronome();
    }
  }

  void _startMetronome() {
    setState(() {
      isRunning = true;
    });

    final interval = Duration(milliseconds: (60000 / bpm).round());
    timer?.cancel();

    timer = Timer.periodic(interval, (timer) async {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();

      if (showPendulum) {
        // Анимация для маятника
        if (_pendulumAnimationController.status == AnimationStatus.completed) {
          _pendulumAnimationController.reverse();
        } else {
          _pendulumAnimationController.forward();
        }
      } else {
        // Анимация для пульсирующего круга
        _circleAnimationController
          ..reset()
          ..forward();
      }
    });
  }

  void _stopMetronome() {
    setState(() {
      isRunning = false;
    });
    timer?.cancel();
    _audioPlayer.stop();
    _pendulumAnimationController.stop();
    _circleAnimationController.stop();
  }

  void _toggleDisplay() {
    setState(() {
      showPendulum = !showPendulum; // Переключение между маятником и кругом
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    _pendulumAnimationController.dispose();
    _circleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Метроном'),
        actions: [
          IconButton(
            icon: Icon(showPendulum ? Icons.circle : Icons.swap_horiz),
            onPressed: _toggleDisplay,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Темп (BPM)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              bpm.toString(),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: bpm.toDouble(),
              min: 40,
              max: 240,
              divisions: 200,
              label: '$bpm BPM',
              onChanged: (value) {
                setState(() {
                  bpm = value.toInt();
                  final duration = Duration(milliseconds: (60000 / bpm).round());
                  _pendulumAnimationController.duration = duration;
                  _circleAnimationController.duration = duration;
                });
              },
            ),
            const SizedBox(height: 16),

            // Отображение маятника или круга
            Expanded(
              child: Center(
                child: showPendulum
                    ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Основание маятника
                    Container(
                      width: 100,
                      height: 10,
                      color: Colors.black,
                    ),
                    // Маятник
                    AnimatedBuilder(
                      animation: _pendulumAnimationController,
                      builder: (context, child) {
                        final angle = lerpDouble(-pi / 8, pi / 8, _pendulumAnimationController.value);
                        return Transform.rotate(
                          angle: angle!,
                          origin: const Offset(0, 0), // Основание маятника снизу
                          child: Container(
                            width: 4,
                            height: 250,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ],
                )
                    : AnimatedBuilder(
                  animation: _circleAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _circleAnimationController.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Кнопка запуска/остановки метронома
            ElevatedButton(
              onPressed: _toggleMetronome,
              child: Text(isRunning ? 'Стоп' : 'Старт'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
