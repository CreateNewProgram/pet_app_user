import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playbus/admin/friendboard_screen.dart';
import 'package:playbus/admin/petInfo_screen.dart';
import 'package:playbus/admin/profile_screen.dart';
import 'package:playbus/admin/select_screen.dart';
import 'package:playbus/admin/gps_screen.dart';

import '../components/my_container.dart';

const seedColor = Color(0xff55ffff);
const outPadding = 32.0;

class DynamicColorDemo extends StatelessWidget {
  const DynamicColorDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        /***
         * You can also do this instead of ColorScheme.fromSeed()
         */
        colorSchemeSeed: seedColor,
        brightness: Brightness.dark,
        // colorScheme: ColorScheme.fromSeed(
        //     seedColor: seedColor, brightness: Brightness.dark),
        textTheme: GoogleFonts.notoSansNKoTextTheme(
          Theme.of(context)
              .textTheme, // If this is not set, then ThemeData.light().textTheme is used.
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Theme.of(context).colorScheme.primary),
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white10,
                  Colors.white10,
                  Colors.black12,
                  Colors.black12,
                  Colors.black12,
                  Colors.black12,
                ],
              )),
        ),
        Scaffold(
          backgroundColor: Colors.deepPurpleAccent,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selected,
            elevation: 0,
            onTap: (selected) {
              setState(() {
                _selected = selected;
              });
              switch (_selected) {
                case 0:
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                  break;
                case 2:
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  );
                  break;
                case 4:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => friendboardPage()),
                  );
                  break;
              }
            },
            selectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
            unselectedItemColor: Theme.of(context).colorScheme.onPrimaryContainer,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: "",
                  backgroundColor: Colors.transparent),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: "",
                  backgroundColor: Colors.transparent),
              BottomNavigationBarItem(
                  icon: Icon(Icons.directions_run),
                  label: "",
                  backgroundColor: Colors.transparent),
              BottomNavigationBarItem(
                  icon: Icon(Icons.assistant_navigation),
                  label: "",
                  backgroundColor: Colors.transparent),
              BottomNavigationBarItem(
                  icon: Icon(Icons.newspaper_outlined),
                  label: "",
                  backgroundColor: Colors.transparent),
            ],
          ),

          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(outPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pets,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: outPadding,
                  ),
                  Text(
                    '산책 도우미 앱',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '반려견을 소중히 다뤄요!',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  const SizedBox(
                    height: outPadding,
                  ),
                  const _TopCard(),
                  const SizedBox(
                    height: outPadding,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '산책 나가기 전 필독 !',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                              color:
                              Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: outPadding,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: MyContainer(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '장난감 이미지',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '링크',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: outPadding,
                                ),
                                Flexible(
                                  flex: 2,
                                  child: MyContainer(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '실종 관련 기사',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '링크',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(
                          width: outPadding,
                        ),
                        Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: MyContainer(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '산책 시 주의사항',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '링크',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: outPadding,
                                ),
                                Flexible(
                                  flex: 3,
                                  child: MyContainer(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '먹이 이미지',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '링크',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16)
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}


class _TopCard extends StatelessWidget {
  const _TopCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘은 산책을 나가셨나요?',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          Text(
            '산책 관련 좋은점 링크 넣어',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}
