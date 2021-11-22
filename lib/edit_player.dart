import 'package:audio_skazki/player_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_cliper.dart';
import 'custom_slider.dart';
import 'package:provider/src/provider.dart';
import 'dart:io';

class EditPlayer extends StatelessWidget {
  const EditPlayer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        ClipPath(
          clipper: MyCustomClipper(),
          child: Container(
            height: height * 0.6,
            color: Colors.deepPurple,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: DraggableScrollableSheet(
              initialChildSize: 0.92,
              builder: (context, controller) {
                return SingleChildScrollView(
                  child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 30, bottom: 20),
                            child: Row(
                              children: [
                                GestureDetector(
                                  child: const Text(
                                    'Отменить',
                                    style: TextStyle(
                                        color: Color(0xFF4a4a97),
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onTap: context.read<PlayerBloc>().cancel,
                                ),
                                const SizedBox(
                                  width: 200,
                                ),
                                GestureDetector(
                                  child: const Text(
                                    'Сохранить',
                                    style: TextStyle(
                                        color: Color(0xFF4a4a97),
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onTap: context.read<PlayerBloc>().ready,
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<String>(
                              stream: context.read<PlayerBloc>().playerPhotoStream,
                              builder: (context, snapshot) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: GestureDetector(
                                    onTap: () {
                                      context
                                          .read<PlayerBloc>()
                                          .showChoiceDialog(context);
                                    },
                                    child: snapshot.data == null
                                        ? Container(
                                      width: 230,
                                      height: 240,
                                      color: Colors.white.withOpacity(0.2),
                                    )
                                        : Image.file(
                                      File(snapshot.data!),
                                      width: 230,
                                      height: 240,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                );
                              }),
                          Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 13, left: 50, right: 50),
                              child: TextField(
                                style: const TextStyle(
                                    color: Color(0xFF4a4a97),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                                controller: context
                                    .read<PlayerBloc>()
                                    .audioPlayerNameController,
                              )),
                          StreamBuilder<double>(
                              initialData: 0.0,
                              stream: context
                                  .read<PlayerBloc>()
                                  .maxPlayerDurationStream,
                              builder: (context, snapshotDuration) {
                                return StreamBuilder<double>(
                                    initialData: 0.0,
                                    stream: context
                                        .read<PlayerBloc>()
                                        .sliderCurrentPositionStream,
                                    builder:
                                        (context, snapshotCurrentPosition) {
                                      return SliderTheme(
                                        data: const SliderThemeData(
                                          activeTrackColor: Color(0xFF4a4a97),
                                          inactiveTrackColor: Color(0xFF4a4a97),
                                          thumbShape:
                                              CustomSlider(thumbRadius: 7),
                                        ),
                                        child: Slider(
                                            min: 0.0,
                                            max: snapshotDuration.data!,
                                            value:
                                                snapshotCurrentPosition.data!,
                                            onChanged: (value) {
                                              context
                                                  .read<PlayerBloc>()
                                                  .seekToPlayer(value.toInt());
                                            }),
                                      );
                                    });
                              }),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 265, left: 25),
                                child: StreamBuilder<String>(
                                    initialData: '00:00',
                                    stream: context
                                        .read<PlayerBloc>()
                                        .playerTxtStream,
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data!,
                                        style: const TextStyle(
                                          color: Color(0xFF4a4a97),
                                        ),
                                      );
                                    }),
                              ),
                              StreamBuilder<String>(
                                  initialData: '00:00',
                                  stream:
                                      context.read<PlayerBloc>().durationStream,
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data!,
                                      style: const TextStyle(
                                        color: Color(0xFF4a4a97),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 50, bottom: 80),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: context.read<PlayerBloc>().rewind,
                                  child: SvgPicture.asset(
                                    'assets/svg_files/rewind.svg',
                                    color: const Color(0xFF4a4a97),
                                  ),
                                ),
                                const SizedBox(
                                  width: 50,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.read<PlayerBloc>().playOrStop();
                                  },
                                  child: StreamBuilder<bool>(
                                      initialData: true,
                                      stream: context
                                          .read<PlayerBloc>()
                                          .isPlayingStream,
                                      builder: (context, snapshot) {
                                        return Container(
                                          height: 75,
                                          width: 75,
                                          decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                          ),
                                          child: snapshot.data == true
                                              ? const Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                )
                                              : const Icon(
                                                  Icons.pause,
                                                  color: Colors.white,
                                                ),
                                        );
                                      }),
                                ),
                                const SizedBox(
                                  width: 50,
                                ),
                                GestureDetector(
                                  onTap: context.read<PlayerBloc>().fastForward,
                                  child: SvgPicture.asset(
                                    'assets/svg_files/fast_forward.svg',
                                    color: const Color(0xFF4a4a97),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                );
              }),
        )
      ],
    );
  }
}