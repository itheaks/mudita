import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mudita',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFB89975, {
          50: Color(0xFFEDE4DB),
          100: Color(0xFFDBC9B0),
          200: Color(0xFFC9AF87),
          300: Color(0xFFB89975),
          400: Color(0xFFA3876A),
          500: Color(0xFF8D775F),
          600: Color(0xFF7B6A54),
          700: Color(0xFF6A5D4A),
          800: Color(0xFF594F3F),
          900: Color(0xFF483233),
        }),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animationController.forward();

    _checkLoggedInStatus(); // Check if user is already logged in
  }

  void _checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      // User is already logged in, navigate to the home page
      _navigateToHomePage();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  Future<void> _setLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  void _continueToHomePage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await _saveName(_nameController.text.trim());
      await _setLoggedInStatus(); // Set the logged-in status
      _navigateToHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter your name'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimationLimiter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 200.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: <Widget>[
                    SizedBox(height: 16.0),
                    Center(
                      child: Image.asset(
                        'asset/logo.png',
                        width: 400,
                        height: 400,
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _continueToHomePage,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late String _username;

  @override
  void initState() {
    super.initState();
    _getUsername();
  }

  Future<void> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Mudita $_username'),
        backgroundColor: Color(0xFFB89975),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB89975),
              Colors.white,
              // Colors.greenAccent,
              // Colors.blueAccent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            _buildScreens(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: kBottomNavigationBarHeight,
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.event),
                      label: 'Events',
                      backgroundColor: Color(0xFFB89975),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.explore),
                      label: 'Explore',
                      backgroundColor: Color(0xFFB89975),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'About',
                      backgroundColor: Color(0xFFB89975),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.contact_page),
                      label: 'Contact us',
                      backgroundColor: Color(0xFFB89975),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreens() {
    final List<Widget> screens = [
      EventScreen(),
      ExploreScreen(),
      AboutScreen(),
      ContactusScreen(),
    ];
    return screens[_currentIndex];
  }
}

// flutter pub run flutter_launcher_icons:main


class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<String> images = [
    'asset/image1.png',
    'asset/image2.png',
    'asset/image3.png',
    'asset/image4.png',
  ];

  List<String> headings = [
    'Heading 1',
    'Heading 2',
    'Heading 3',
    'Heading 4',
  ];

  List<String> texts = [
    'Text 1',
    'Text 2',
    'Text 3',
    'Text 4',
  ];

  List<int> currentIndexes = [0, 0, 0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom:80.0),
      child: Center(
        child: AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 500),
          child: Container(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 500),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          'MUDITA ONGOING EVENTS',
                          style: TextStyle(
                            fontSize: 27.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          'Valuable Vintage',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CarouselSlider(
                        items: images.map((image) {
                          return Container(
                            margin: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            // Update the current index when the page changes
                            setState(() {
                              currentIndexes[0] = index;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        headings[currentIndexes[0]],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        texts[currentIndexes[0]],
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          'Joyful Learning',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CarouselSlider(
                        items: images.map((image) {
                          return Container(
                            margin: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            // Update the current index when the page changes
                            setState(() {
                              currentIndexes[1] = index;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        headings[currentIndexes[1]],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        texts[currentIndexes[1]],
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          'Amhiti',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CarouselSlider(
                        items: images.map((image) {
                          return Container(
                            margin: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            // Update the current index when the page changes
                            setState(() {
                              currentIndexes[2] = index;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        headings[currentIndexes[2]],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        texts[currentIndexes[2]],
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          'MUDITA UPCOMING EVENTS',
                          style: TextStyle(
                            fontSize: 27.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          'Food waste management',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CarouselSlider(
                        items: images.map((image) {
                          return Container(
                            margin: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            // Update the current index when the page changes
                            setState(() {
                              currentIndexes[3] = index;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        headings[currentIndexes[3]],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        texts[currentIndexes[3]],
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          'Pawsitivity',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CarouselSlider(
                        items: images.map((image) {
                          return Container(
                            margin: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            // Update the current index when the page changes
                            setState(() {
                              currentIndexes[4] = index;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        headings[currentIndexes[4]],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        texts[currentIndexes[4]],
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text(
                          'Blood Donation',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CarouselSlider(
                        items: images.map((image) {
                          return Container(
                            margin: EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            // Update the current index when the page changes
                            setState(() {
                              currentIndexes[5] = index;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        headings[currentIndexes[5]],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        texts[currentIndexes[5]],
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class ExploreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 500),
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'YET TO UPDATE',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 500),
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'YET TO UPDATE',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class ContactusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 500),
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'YET TO UPDATE',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

