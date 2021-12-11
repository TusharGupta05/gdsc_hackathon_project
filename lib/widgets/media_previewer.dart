import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:gdsc_hackathon_project/enums/media_type.dart';
import 'package:gdsc_hackathon_project/functions/helper.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/models/media.dart';
import 'package:provider/provider.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

class MediaPreviewer extends StatelessWidget {
  final List<Media> mediaList;
  const MediaPreviewer({Key? key, required this.mediaList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImagesSlider(mediaList: mediaList);
  }
}

class ImagesSlider extends StatelessWidget {
  final List<Media> mediaList;

  const ImagesSlider({required this.mediaList});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MediaSliderIndex(0),
        builder: (_, __) {
          return Column(
            children: [
              Consumer<MediaSliderIndex>(builder: (_, mediaSliderIndex, __) {
                return CarouselSlider(
                  options: CarouselOptions(
                      viewportFraction: 1,
                      height: 200,
                      enableInfiniteScroll: false,
                      // disableCenter: true,
                      enlargeCenterPage: true,
                      onPageChanged: (idx, _) {
                        mediaSliderIndex.update(idx);
                      }),
                  items: List<Widget>.generate(
                    mediaList.length,
                    (idx) {
                      if (mediaList[idx].mediaType == MediaType.Image) {
                        return GestureDetector(
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Download started. Check notifications for more info.'),
                              duration: Duration(seconds: 1),
                            ));
                            await Helper.downloadFile(mediaList[idx]);
                          },
                          child: CachedNetworkImage(
                            imageUrl: mediaList[idx].url,
                          ),
                        );
                      }
                      return Container(
                        child: TextButton(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Download started. Check notifications for more info.'),
                              duration: Duration(seconds: 1),
                            ));
                            await Helper.downloadFile(mediaList[idx]);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Center(
                                      child: Image.asset(
                                          'assets/icons/file.png'))),
                              Expanded(
                                  flex: 1,
                                  child: Center(
                                      child: Text(
                                          'Download file - ${mediaList[idx].name}'))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
              if (mediaList.length > 1) const SizedBox(height: 20),
              if (mediaList.length > 1)
                Consumer<MediaSliderIndex>(builder: (_, mediaSliderIndex, __) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(
                      mediaList.length,
                      (idx) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            shape: BoxShape.circle,
                            color: idx == mediaSliderIndex.idx
                                ? Colors.black
                                : Colors.white),
                      ),
                    ),
                  );
                }),
            ],
          );
        });
  }
}

class MediaSliderIndex extends ChangeNotifier {
  int idx;
  MediaSliderIndex(this.idx);
  void update(int idx) {
    this.idx = idx;
    notifyListeners();
  }
}
