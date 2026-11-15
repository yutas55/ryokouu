// ---- Data akun ----
String namaPengguna = 'Sigma';
String noHpPengguna = '+62812-3456-7890';

// ---- Status sewa ----
// true  -> kotak hijau "Sedang Menyewa <motor>" + tombol "Lihat Detail Penyewaan"
// false -> kotak abu-abu "Belum Menyewa Motor" + tombol "Sewa Sekarang!"
bool sewaMotor = false;
String motorYangDisewa = 'Vario 125'; // dipakai kalau sewaMotor = true

// ---- Jenis denda (true = pengguna memiliki denda itu) ----
// Kalau ada yang true: tombol jadi merah "Anda Memiliki Denda",
// tanda seru muncul di bagian Denda, dan jumlahnya ikut bertambah.
bool dendaKeterlambatan = false;
bool dendaKerusakan = false;
bool dendaKeluarWilayah = false;

// ---- Dihitung otomatis dari variabel di atas (jangan diubah) ----
List<String> get daftarDenda => [
  if (dendaKeterlambatan) 'Denda Keterlambatan',
  if (dendaKerusakan) 'Denda Kerusakan',
  if (dendaKeluarWilayah) 'Denda Keluar Wilayah',
];

int get jumlahDenda => daftarDenda.length;

bool get punyaDenda => jumlahDenda > 0;