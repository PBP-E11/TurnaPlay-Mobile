import 'package:flutter/material.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/creationForm.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showButton) {
      setState(() {
        _showButton = true;
      });
    } else if (_scrollController.offset <= 200 && _showButton) {
      setState(() {
        _showButton = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur dasar halaman dengan AppBar dan body.
    return Scaffold(
      // AppBar adalah bagian atas halaman yang menampilkan judul.
      appBar: AppBar(
        // Judul aplikasi "Football News" dengan teks putih dan tebal.
        title: const Text(
          'TurnaPlay',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Warna latar belakang AppBar diambil dari skema warna tema aplikasi.
        backgroundColor: const Color(0xFF494598),
      ),
      // Body halaman dengan padding di sekelilingnya.
      body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Menyusun widget secara vertikal dalam sebuah kolom.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Row untuk menampilkan 3 InfoCard secara horizontal.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                     InfoCard(title: "Tournaments", content: "10 Active"),
                     InfoCard(title: "Players", content: "150 Online"),
                     InfoCard(title: "Matches", content: "5 Live"),
                  ],
                ),

                // Memberikan jarak vertikal 16 unit.
                const SizedBox(height: 16.0),

                // Menempatkan widget berikutnya di tengah halaman.
                Center(
                  child: Column(
                    // Menyusun teks dan grid item secara vertikal.
                    children: [
                      const Text(
                        'Upcoming Tournaments',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // Grid untuk menampilkan ItemCard dalam bentuk grid 3 kolom.
                      GridView.count(
                        primary: false, // Use false because we have a controller on parent
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 3,
                        // Agar grid menyesuaikan tinggi kontennya.
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Let SingleChildScrollView handle scroll

                        // Menampilkan ItemCard untuk setiap item dalam list items.
                        children: List.generate(30, (index) {
                          return Card(
                            color: Colors.deepPurple[100],
                            child: Center(
                              child: Text(
                                'Tournament ${index + 1}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _showButton
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TournamentCreationForm(),
                  ),
                );
              },
              label: const Text('Create Tournament'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan title dan content.

  final String title;  // Judul kartu.
  final String content;  // Isi kartu.

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Membuat kotak kartu dengan bayangan dibawahnya.
      elevation: 2.0,
      child: Container(
        // Mengatur ukuran dan jarak di dalam kartu.
        width: MediaQuery.of(context).size.width / 3.5, // menyesuaikan dengan lebar device yang digunakan.
        padding: const EdgeInsets.all(16.0),
        // Menyusun title dan content secara vertikal.
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}