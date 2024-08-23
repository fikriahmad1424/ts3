import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Main entry point
void main() {
  runApp(MyApp());
}

// Main Application Widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMK Negeri 4 - Student Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          secondary: const Color.fromARGB(255, 102, 143, 162), // Use colorScheme for secondary color
        ),
      ),
      home: TabScreen(),
    );
  }
}

// TabScreen with three tabs
class TabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('SMK Negeri 4 - Student Portal'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.group), text: 'Students'),
              Tab(icon: Icon(Icons.account_circle), text: 'Profile'),
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            DashboardTab(),
            StudentsTab(),
            ProfileTab(),
          ],
        ),
      ),
    );
  }
}

// Layout for Dashboard Tab

class DashboardTab extends StatelessWidget {
  // Define color constants
  static const Color lightBlue = Color.fromARGB(255, 110, 122, 125);
  static const Color darkBlue = Color.fromARGB(255, 40, 41, 42);

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.book, 'label': 'Academics'},
    {'icon': Icons.calendar_today, 'label': 'Attendance'},
    {'icon': Icons.assessment, 'label': 'Grades'},
    {'icon': Icons.notifications, 'label': 'Announcements'},
    {'icon': Icons.calendar_view_day, 'label': 'Timetable'},
    {'icon': Icons.message, 'label': 'Messages'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of items per row
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return GestureDetector(
            onTap: () {
              // Handle tap on the menu icon
              print('${item['label']} tapped');
            },
            child: Card(
              elevation: 8.0, // Increased elevation for a more pronounced shadow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Rounded corners
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [lightBlue, darkBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0), // Match border radius
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'],
                      size: 50.0,
                      color: Colors.white, // White icon for contrast
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      item['label'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0, // Increased font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text for contrast
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



// Layout for Students Tab
class StudentsTab extends StatefulWidget {
  @override
  _StudentsTabState createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  List<User> _allStudents = [];
  List<User> _filteredStudents = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchStudents().then((students) {
      setState(() {
        _allStudents = students;
        _filteredStudents = students;
      });
    });
  }

  Future<List<User>> fetchStudents() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users?page=2'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  void _filterStudents(String query) {
    List<User> filteredList = _allStudents
        .where((student) => student.firstName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _searchQuery = query;
      _filteredStudents = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Search bar for searching students
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search Students',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                _filterStudents(value);
              },
            ),
          ),
          Expanded(
            child: _filteredStudents.isEmpty && _searchQuery.isNotEmpty
                ? Center(child: Text('No students found'))
                : ListView.builder(
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final user = _filteredStudents[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.black,
                            child: Text(
                              user.firstName[0],
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          title: Text(
                            user.firstName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(user.email),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                          onTap: () {
                            // Handle onTap, e.g., navigate to a detailed profile page
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


// Layout for Profile Tab
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = 'Fikri';
  String _email = 'ahmadhafid@gmail.com';

  void _updateProfile(String name, String email) {
    setState(() {
      _name = name;
      _email = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 211, 209, 213)], // Gradien biru langit
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTell7JMP2GE4UzCY42JwPdEZi1s-3FZCvpoQ&s'), // Perbarui path gambar
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    _name,  // Gunakan nama terbaru
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    _email,  // Gunakan email terbaru
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(179, 255, 255, 255),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Profil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.person, color: const Color.fromARGB(255, 107, 112, 122)),
                          title: Text('Nama Lengkap'),
                          subtitle: Text(_name),  // Gunakan nama terbaru
                        ),
                        ListTile(
                          leading: Icon(Icons.cake, color: const Color.fromARGB(255, 107, 112, 122)),
                          title: Text('Tanggal Lahir'),
                          subtitle: Text('1 Januari 2000'),
                        ),
                        ListTile(
                          leading: Icon(Icons.phone, color: const Color.fromARGB(255, 107, 112, 122)),
                          title: Text('Nomor Kontak'),
                          subtitle: Text('+62 123 456 7890'),
                        ),
                        ListTile(
                          leading: Icon(Icons.location_on, color: const Color.fromARGB(255, 107, 112, 122)),
                          title: Text('Alamat'),
                          subtitle: Text('Jl. Contoh No. 123, Jakarta'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              name: _name,
                              email: _email,
                              onProfileUpdated: _updateProfile,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Edit Profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 0, 0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Tangani aksi logout
                      },
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 254, 0, 0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Layar Edit Profil
class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final Function(String, String) onProfileUpdated;

  EditProfileScreen({required this.name, required this.email, required this.onProfileUpdated});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _email = widget.email;
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Panggil callback untuk memperbarui profil di ProfileTab
      widget.onProfileUpdated(_name, _email);

      // Kembali ke tab Profil setelah perubahan disimpan
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nama Lengkap'),
                onChanged: (value) => setState(() => _name = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan nama lengkap';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Alamat Email'),
                onChanged: (value) => setState(() => _email = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan alamat email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Mohon masukkan alamat email yang valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// User model
class User {
  final String firstName;
  final String email;

  User({required this.firstName, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      email: json['email'],
    );
  }
}