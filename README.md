# TurnaPlay

## E-11 : 
- Jose Ryu Toari - 2406495981
- Karla Ameera Raswanda - 2406414542
- Muhammad Fahri Muharram - 2406404705
- Muhammad Hadziqul Falah Teguh - 2406437432
- Tangguh Ambha Wahyuga - 2406361536

## Download
Download aplikasi versi terbaru: [Download APK](https://app.bitrise.io/app/226353bf-9ef4-4b88-9e6a-5b49841f802e/installable-artifacts/87445c28791a6eb3/public-install-page/f071cb4f364640f563f2f7ecee29db81)

## Promotion/Overview Video
Lihat video aplikasi kita di tautan berikut : [Video](https://drive.google.com/file/d/1Ga7Cy50KVqZTsL8JbaPosBf8Xy9vtfUp/view?usp=sharing)

## Deskripsi Aplikasi

TurnaPlay adalah sebuah aplikasi yang berfungsi sebagai pusat informasi turnamen esport di Indonesia. Platform ini hadir untuk menjawab masalah yang sering dialami para gamers, yaitu sulitnya menemukan informasi lomba karena tersebar di berbagai akun media sosial seperti instagram. Melalui TurnaPlay, semua informasi turnamen dikumpulkan, disaring, dan diverifikasi agar pengguna bisa mendapatkan data yang akurat dan terstruktur dalam satu tempat. 

Tujuan utama TurnaPlay adalah menghemat waktu para gamers sekaligus membantu penyelenggara menjangkau peserta lebih luas. Dengan fitur filter berdasarkan game pengguna dapat dengan mudah menemukan turnamen yang sesuai dengan minat dan kemampuannya.

## Daftar Modul
Semua operasi CRUD hanya dapat dilakukan oleh pengguna yang sudah login sesuai hak aksesnya (atau admin), kecuali jika ditandai (dengan garis bawah/underscore). Fields hanyalah deskripsi singkat sebagian data penting dan bagaimana interaksi antar modul.

### 1. Tournament - (Falah + Fahri)
* **Create**: membuat kompetisi. _admin only_
* **Read**: membaca info publik kompetisi (tanggal mulai, hadiah, dll).
* **Update**: memperbarui info kompetisi. _admin only_
* **Delete**: menghapus kompetisi. _admin only_
* **Fields**: PK id, tanggal\_mulai, hadiah, thumbnail, etc.

### 2. User - (Ambha)
* **Create**: membuat profil (display name, site username, email, password).
* **Read**: membaca profil. _public access_
* **Update**: memperbarui profil.
* **Delete**: menghapus profil/akun.
* **Fields**: PK id, site\_username UNIQUE, email UNIQUE, password_hash, display\_name.

### 3. Game Account - (Jose)
* **Create**: membuat akun (game category, ingame name)
* **Read**: membaca akun _public access_
* **Update**: mengubah detail akun
* **Delete**: menghapus akun
* **Fields**: PK id, FK user.id, game\_category, ingame\_name, active
* **Constraint**: (game\_category, ingame\_name) UNIQUE

### 4. Tournament Invite - (Karla)
* **Create**: mengundang pengguna untuk bergabung dalam kompetisi
* **Read**: melihat detail invite (kompetisi terkait, anggota tim, kapten)
* **Update**: menerima atau menolak invite
* **Delete**: membatalkan invite
* **Fields**: PK id, FK user.id, FK tournament\_id, status

### 5. Team-member (terikat many-to-many tournament\_registration dan user account) - (Fahri + Karla)
* **Create**: menambahkan akun ke tim
* **Read**: melihat anggota tim __public__
* **Update**: ubah akun yang digunakan pada tim
* **Delete**: mengeluarkan akun dari tim __user/leader__
* **Fields**: PK id, FK account.id, FK tournament\_registration.id

### 6. Tournament Registration/Team Detail (Fahri)
* **Create**: membuat tim saat registration
* **Read**: menampilkan detail tim dan kredensial
* **Update**: mengedit detail tim, misalnya nama tim
* **Delete**: membatalkan pendaftaran kompetisi dan membubarkan tim
* **Fields**: PK id, team_name

## Sumber Dataset

Sumber dataset TurnaPlay berasal dari akun Instagram atas nama @infotournament [link](https://www.instagram.com/infotournament/). Dari akun tersebut kami mengambil inspirasi app kami. Akun tersebut menyediakan post-post turnamen dari berbagai game dari berbagai platform seperti Mobile Legend, Valorant, PUBG, dan lain sebagainya. Permohonan izin sudah dilakukan dan kami tentunya akan mencantumkan kredit website kita kepada akun tersebut.

## Role atau peran pengguna

Pada app TurnaPlay, akan tersedia beberapa role yang membantu kelancaran aplikasi:

### User
User merupakan role untuk para pengguna yang mendaftarkan diri untuk masuk ke turnamen.
Suatu hal yang harus diperhatikan disini adalah untuk turnamen kelompok; pendaftaran pada suatu turnamen dilakukan oleh leader.
Leader di sini akan mendaftarkan meng-invite anggota tim, di mana masing-masing anggota dapat menerima atau menolak invite bergabung ke dalam tim.
Masing-masing anggota mendaftarkan detail akun ingame khusus game tersebut.
eader dapat pula membatalkan invite ataupun mengganti anggota tim sebelum dimulainya kompetisi.

### Organizer
Merupakan orang/pihak yang menyelenggarakan turnamen.
Organizer memiliki akses membuat turnamen dengan ketentuan yang diinginkan seperti jumlah anggota, jumlah hadiah, dll.
Pembuatan turnamen oleh organizer nantinya akan masuk ke display list-list turnamen yang dapat dilihat oleh user.
**User dengan role organizer dibuat oleh admin.**

### Admin
Admin tetap memiliki privilege untuk melihat turnamen layaknya user biasa meskipun sebenarnya tidak berkepentingan.
Admin juga dapat mengisi dan mengubah detail turnamen jika pihak organizer tidak dapat melakukan secara langsung.
Hak spesial admin adalah dapat menutup suatu turnamen dan menghapus/memblokir user/akun.
Fitur tersebut diadakan guna untuk mengatasi situasi adanya turnamen atau pengguna melanggar SOP  dari TurnaPlay.
**User dengan role admin dibuat oleh admin.**

## Pengintegrasian Dengan Django API
Autentikasi
- Register -> POST /api/accounts/register
- Login -> POST /api/accounts/login

Tournament
- Create Tournament -> POST /api/create-tournament
- View Tournament -> GET /api/tournaments
- Delete Tournament -> DELETE /api/delete-tournament

Game Account
- Buat Game Account -> POST /api/game-account/create
- List Game Account -> GET /api/game-account/list
- Edit Game Account -> POST /api/game-account/update
- Delete Game Account -> DELETE /api/game-account/delete

Team & Registration
- Daftar Tim Baru -> POST /api/team/create
- Update Nama Tim -> POST /api/team/update
- Dapatkan Detail Tim -> POST /api/team/details
- Bubarkan Tim -> POST /api/team/delete
- Masuk Tim -> POST /api/team/member/join
- Edit Game Account Pada Tim -> POST /api/team/member/update
- Keluar dari Tim -> POST /api/team/member/delete

Invite
- Buat Invite Tim -> POST /api/invites/send
- Cek Invite Yang Ada -> GET /api/invites/incoming
- Cek Invite Yang Baru Muncul -> GET /api/invites/new
- Balas Invite -> POST /api/invites/respond

Dashboard
- User Dashboard -> GET /api/dashbord
- User List -> GET /api/dashboard/users
- Buat Akun Organizer -> POST /api/dashboard/users/create-organizer
- Detail User -> GET /api/dashboard/users
- Hapus User -> DELETE /api/dashboard/users
