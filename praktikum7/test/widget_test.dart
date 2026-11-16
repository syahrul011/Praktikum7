import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum7/main.dart';

void main() {
  testWidgets('1. Tiga data awal dimuat beserta counter', (WidgetTester tester) async {
    await tester.pumpWidget(const PraktikumApp());

    // Memverifikasi teks judul AppBar
    expect(find.text('Praktikum 7 - Pemrograman Mobile'), findsOneWidget);

    // Memverifikasi data awal mahasiswa
    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('Siti'), findsOneWidget);
    expect(find.text('Fatimah Zahro'), findsOneWidget);

    // Memverifikasi NIM dan Prodi
    expect(find.text('Informatika | 2026001'), findsOneWidget);
    expect(find.text('Informatika | 2026002'), findsOneWidget);
    expect(find.text('Sistem Informasi | 240112003'), findsOneWidget);

    // Memverifikasi counter data
    expect(find.text('Tersimpan: 3'), findsOneWidget);
    expect(find.text('Ditemukan: 3'), findsOneWidget);
  });

  testWidgets('2. Validasi form: kosong, non-angka, minimal 6 digit, dan duplikasi NIM',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PraktikumApp());

    // Buka form dialog tambah
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Data Mahasiswa'), findsOneWidget);

    // Klik simpan tanpa mengisi form (uji required)
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('NIM wajib diisi'), findsOneWidget);
    expect(find.text('Nama lengkap wajib diisi'), findsOneWidget);
    expect(find.text('Program studi wajib diisi'), findsOneWidget);

    // Uji validasi non-angka (Tantangan A)
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nomor Induk Mahasiswa (NIM)'), 'abc123');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('NIM hanya boleh berisi angka'), findsOneWidget);

    // Uji validasi panjang NIM < 6 digit (Tantangan A)
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nomor Induk Mahasiswa (NIM)'), '12345');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('NIM minimal 6 digit'), findsOneWidget);

    // Uji duplikasi NIM
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nomor Induk Mahasiswa (NIM)'), '2026001');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('NIM sudah digunakan oleh mahasiswa lain'), findsOneWidget);

    // Tutup dialog
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Data Mahasiswa'), findsNothing);
  });

  testWidgets('3. Tambah data mahasiswa valid (CREATE)', (WidgetTester tester) async {
    await tester.pumpWidget(const PraktikumApp());

    // Buka form
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Isi formulir valid
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nomor Induk Mahasiswa (NIM)'), '240111099');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Lengkap Mahasiswa'), 'Budi Santoso');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Program Studi'), 'Sistem Informasi');

    // Simpan
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Pastikan data baru muncul
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Sistem Informasi | 240111099'), findsOneWidget);
    expect(find.text('Tersimpan: 4'), findsOneWidget);
    expect(find.text('Ditemukan: 4'), findsOneWidget);
  });

  testWidgets('4. Ubah data mahasiswa (UPDATE)', (WidgetTester tester) async {
    await tester.pumpWidget(const PraktikumApp());

    // Cari tombol edit pada kartu Andi (ikon edit pertama)
    final editIcons = find.byIcon(Icons.edit);
    await tester.tap(editIcons.first);
    await tester.pumpAndSettle();

    expect(find.text('Ubah Data Mahasiswa'), findsOneWidget);

    // Ubah nama dari Andi menjadi Andi Pratama
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Lengkap Mahasiswa'), 'Andi Pratama');

    // Simpan (NIM tetap sama, tidak boleh kena validasi duplikat)
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Andi Pratama'), findsOneWidget);
    expect(find.text('Andi'), findsNothing);
  });

  testWidgets('5. Hapus data dengan konfirmasi dan batalkan (DELETE)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PraktikumApp());

    final deleteIcons = find.byIcon(Icons.delete);
    // Tap delete pada Siti
    await tester.tap(deleteIcons.at(1));
    await tester.pumpAndSettle();

    expect(find.text('Hapus data?'), findsOneWidget);
    expect(find.text('Hapus data mahasiswa Siti (NIM: 2026002)?'), findsOneWidget);

    // Klik Batal
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    // Siti tetap ada
    expect(find.text('Siti'), findsOneWidget);
    expect(find.text('Tersimpan: 3'), findsOneWidget);
  });

  testWidgets('6. Hapus data dan Batalkan via SnackBar Undo (Tantangan D)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PraktikumApp());

    final deleteIcons = find.byIcon(Icons.delete);
    // Hapus Andi
    await tester.tap(deleteIcons.first);
    await tester.pumpAndSettle();

    // Konfirmasi Hapus
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    // Andi terhapus
    expect(find.text('Andi'), findsNothing);
    expect(find.text('Tersimpan: 2'), findsOneWidget);

    // SnackBar muncul
    expect(find.text('Data "Andi" dihapus'), findsOneWidget);
    expect(find.text('BATALKAN'), findsOneWidget);

    // Klik BATALKAN
    await tester.tap(find.text('BATALKAN'));
    await tester.pumpAndSettle();

    // Andi kembali
    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('Tersimpan: 3'), findsOneWidget);
  });

  testWidgets('7. Pencarian case-insensitive dan tombol hapus pencarian (SEARCH)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PraktikumApp());

    // Masukkan kata kunci pencarian campuran "sItI"
    await tester.enterText(find.byType(TextField), 'sItI');
    await tester.pumpAndSettle();

    // Hanya Siti yang muncul
    expect(find.text('Siti'), findsOneWidget);
    expect(find.text('Andi'), findsNothing);
    expect(find.text('Fatimah Zahro'), findsNothing);
    expect(find.text('Tersimpan: 3'), findsOneWidget);
    expect(find.text('Ditemukan: 1'), findsOneWidget);

    // Tombol clear pencarian (ikon clear)
    expect(find.byIcon(Icons.clear), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    // Semua data kembali tampil
    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('Siti'), findsOneWidget);
    expect(find.text('Fatimah Zahro'), findsOneWidget);
    expect(find.text('Ditemukan: 3'), findsOneWidget);
  });

  testWidgets('8. Pengurutan nama secara alfabetis A-Z (Tantangan C)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PraktikumApp());

    // Urutan awal: Andi (index 0), Siti (index 1), Fatimah Zahro (index 2)
    // Aktifkan pengurutan A-Z via tombol toggle di AppBar
    await tester.tap(find.byTooltip('Urutkan A-Z'));
    await tester.pumpAndSettle();

    // Setelah diurutkan A-Z:
    // 1. Andi
    // 2. Fatimah Zahro
    // 3. Siti
    final listTiles = find.byType(ListTile);
    expect(listTiles, findsNWidgets(3));

    // Dapatkan teks nama pada ListTile urutan ke-2 (indeks 1)
    final secondTile = find.descendant(of: listTiles.at(1), matching: find.text('Fatimah Zahro'));
    expect(secondTile, findsOneWidget);

    // Kembalikan ke urutan normal
    await tester.tap(find.byTooltip('Urutan Normal'));
    await tester.pumpAndSettle();

    // Pada posisi kedua kembali Siti
    final restoredSecondTile = find.descendant(of: listTiles.at(1), matching: find.text('Siti'));
    expect(restoredSecondTile, findsOneWidget);
  });
}
