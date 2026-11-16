import 'package:flutter/material.dart';

void main() {
  runApp(const PraktikumApp());
}

class PraktikumApp extends StatelessWidget {
  const PraktikumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 7 - Pemrograman Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F7FD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.purple.shade50),
          ),
        ),
      ),
      home: const MahasiswaPage(),
    );
  }
}

class MahasiswaPage extends StatefulWidget {
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  // Data mahasiswa awal berbasis RAM
  final List<Map<String, String>> mahasiswa = [
    {
      'id': '1',
      'nim': '2026001',
      'nama': 'Andi',
      'prodi': 'Informatika',
      'ipk': '3.75',
    },
    {
      'id': '2',
      'nim': '2026002',
      'nama': 'Siti',
      'prodi': 'Informatika',
      'ipk': '3.80',
    },
    {
      'id': '3',
      'nim': '240112010',
      'nama': 'Syahrul Setiawan',
      'prodi': 'Sistem Informasi',
      'ipk': '3.90',
    },
  ];

  int nextId = 4;

  // State untuk pencarian
  final TextEditingController searchController = TextEditingController();
  String keyword = '';

  // Fitur Tantangan C: Toggle pengurutan nama A-Z
  bool isSortedAZ = true;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Getter data tampilan (Search & Sort dinamis tanpa mutasi data asli)
  List<Map<String, String>> get dataTampil {
    final q = keyword.trim().toLowerCase();
    List<Map<String, String>> list = mahasiswa.where((m) {
      final nama = (m['nama'] ?? '').toLowerCase();
      final nim = (m['nim'] ?? '').toLowerCase();
      final ipk = (m['ipk'] ?? '').toLowerCase();
      return nama.contains(q) || nim.contains(q) || ipk.contains(q);
    }).toList();

    // Konekkan filter agar selalu terurut sesuai nama A-Z (atau Z-A jika ditoggle)
    list.sort((a, b) {
      final comp = (a['nama'] ?? '')
          .toLowerCase()
          .compareTo((b['nama'] ?? '').toLowerCase());
      return isSortedAZ ? comp : -comp;
    });

    return list;
  }

  // CREATE: Tambah Mahasiswa
  Future<void> tambahData() async {
    final hasil = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => MahasiswaForm(dataSudahAda: mahasiswa),
    );

    if (!mounted || hasil == null) return;

    setState(() {
      mahasiswa.add({'id': '${nextId++}', ...hasil});
    });
  }

  // UPDATE: Ubah Mahasiswa berdasarkan ID unik
  Future<void> ubahData(Map<String, String> dipilih) async {
    final hasil = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => MahasiswaForm(
        dataAwal: dipilih,
        dataSudahAda: mahasiswa,
      ),
    );

    if (!mounted || hasil == null) return;

    final index = mahasiswa.indexWhere((m) => m['id'] == dipilih['id']);
    if (index < 0) return;

    setState(() {
      mahasiswa[index] = {'id': dipilih['id']!, ...hasil};
    });
  }

  // DELETE: Hapus Mahasiswa dengan Konfirmasi & Undo (Tantangan D)
  Future<void> hapusData(Map<String, String> dipilih) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus data?'),
        content: Text(
          'Hapus data mahasiswa ${dipilih['nama']} (NIM: ${dipilih['nim']})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted || setuju != true) return;

    final indexAsli = mahasiswa.indexWhere((m) => m['id'] == dipilih['id']);
    if (indexAsli < 0) return;

    final itemDihapus = Map<String, String>.from(mahasiswa[indexAsli]);

    setState(() {
      mahasiswa.removeAt(indexAsli);
    });

    // Fitur Tantangan D: Undo Penghapusan via SnackBar
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data "${itemDihapus['nama']}" dihapus'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'BATALKAN',
          textColor: const Color(0xFFFFD54F),
          onPressed: () {
            setState(() {
              final safeIndex = indexAsli.clamp(0, mahasiswa.length);
              mahasiswa.insert(safeIndex, itemDihapus);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Praktikum 7 - Pemrograman Mobile',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Fitur Tantangan C: Toggle pengurutan A-Z
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: isSortedAZ ? 'Urutan A-Z (Ketuk untuk Z-A)' : 'Urutan Z-A (Ketuk untuk A-Z)',
              style: IconButton.styleFrom(
                backgroundColor: isSortedAZ ? Colors.purple.shade100 : Colors.purple.shade50,
              ),
              icon: Icon(
                isSortedAZ ? Icons.sort_by_alpha : Icons.sort,
                color: primaryColor,
              ),
              onPressed: () {
                setState(() {
                  isSortedAZ = !isSortedAZ;
                });
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              // Kolom Pencarian
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Cari nama atau NIM',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: keyword.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setState(() => keyword = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (v) => setState(() => keyword = v),
                ),
              ),

              // Baris Status Counter (Tantangan B)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tersimpan: ${mahasiswa.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Ditemukan: ${dataTampil.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Daftar Kartu Mahasiswa
              Expanded(
                child: dataTampil.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mahasiswa.isEmpty
                                  ? 'Belum ada data mahasiswa'
                                  : 'Mahasiswa tidak ditemukan',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: dataTampil.length,
                        itemBuilder: (context, index) {
                          final item = dataTampil[index];
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              title: Text(
                                item['nama'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${item['prodi']} | ${item['nim']} | IPK: ${item['ipk'] ?? '-'}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Ubah',
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () => ubahData(item),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus',
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Color(0xFFE53935),
                                    ),
                                    onPressed: () => hapusData(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple.shade100,
        foregroundColor: const Color(0xFF381E72),
        elevation: 2,
        onPressed: tambahData,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// Widget Dialog Form Mahasiswa
class MahasiswaForm extends StatefulWidget {
  final Map<String, String>? dataAwal;
  final List<Map<String, String>> dataSudahAda;

  const MahasiswaForm({
    super.key,
    this.dataAwal,
    required this.dataSudahAda,
  });

  @override
  State<MahasiswaForm> createState() => _MahasiswaFormState();
}

class _MahasiswaFormState extends State<MahasiswaForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nimController;
  late final TextEditingController namaController;
  late final TextEditingController prodiController;
  late final TextEditingController ipkController;

  @override
  void initState() {
    super.initState();
    nimController = TextEditingController(text: widget.dataAwal?['nim'] ?? '');
    namaController = TextEditingController(text: widget.dataAwal?['nama'] ?? '');
    prodiController =
        TextEditingController(text: widget.dataAwal?['prodi'] ?? '');
    ipkController = TextEditingController(text: widget.dataAwal?['ipk'] ?? '');
  }

  @override
  void dispose() {
    nimController.dispose();
    namaController.dispose();
    prodiController.dispose();
    ipkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.dataAwal != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        isEdit ? 'Ubah Data Mahasiswa' : 'Tambah Data Mahasiswa',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kolom NIM (Tantangan A: Validasi Regex Numerik & Minimal 6 Digit)
              TextFormField(
                controller: nimController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nomor Induk Mahasiswa (NIM)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) {
                    return 'NIM wajib diisi';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(v)) {
                    return 'NIM hanya boleh berisi angka';
                  }
                  if (v.length < 6) {
                    return 'NIM minimal 6 digit';
                  }
                  final sudahAda = widget.dataSudahAda.any((m) =>
                      m['nim'] == v && m['id'] != widget.dataAwal?['id']);
                  if (sudahAda) {
                    return 'NIM sudah digunakan oleh mahasiswa lain';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kolom Nama
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap Mahasiswa',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama lengkap wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // Kolom Program Studi
              TextFormField(
                controller: prodiController,
                decoration: const InputDecoration(
                  labelText: 'Program Studi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Program studi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // Kolom IPK
              TextFormField(
                controller: ipkController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Indeks Prestasi Kumulatif (IPK)',
                  hintText: 'Contoh: 3.75',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) {
                    return 'IPK wajib diisi';
                  }
                  final n = double.tryParse(val.replaceAll(',', '.'));
                  if (n == null) {
                    return 'IPK harus berupa angka desimal (contoh: 3.75)';
                  }
                  if (n < 0.0 || n > 4.0) {
                    return 'IPK harus di antara 0.00 - 4.00';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6750A4),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'nim': nimController.text.trim(),
              'nama': namaController.text.trim(),
              'prodi': prodiController.text.trim(),
              'ipk': ipkController.text.trim().replaceAll(',', '.'),
            });
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
