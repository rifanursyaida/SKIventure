import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage>
    with TickerProviderStateMixin {
  // Controllers
  final _namaCtrl = TextEditingController();
  final _nomorAbsenCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Animasi
  late AnimationController _pageCtrl;
  late AnimationController _cardCtrl;
  late AnimationController _successCtrl;
  late AnimationController _floatCtrl;

  late Animation<double> _pageFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _successScale;
  late Animation<double> _successOpacity;
  late Animation<double> _floatAnim;

  // State
  String? _selectedKelas;
  bool _submitted = false;
  bool _isLoading = false;

  final List<String> _kelasList = [
    '7A', '7B', '7C', '7D',
    '8A', '8B', '8C', '8D',
    '9A', '9B', '9C', '9D',
  ];

  String get _tanggalSekarang {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const hari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final now = DateTime.now();
    final hariStr = hari[now.weekday - 1];
    return '$hariStr, ${now.day} ${bulan[now.month]} ${now.year}';
  }

  String get _jamSekarang {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  @override
  void initState() {
    super.initState();

    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pageFade = CurvedAnimation(
      parent: _pageCtrl,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageCtrl,
      curve: Curves.easeOutCubic,
    ));
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut),
    );
    _successOpacity = CurvedAnimation(
      parent: _successCtrl,
      curve: Curves.easeIn,
    );
    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _pageCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardCtrl.forward();
    });
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nomorAbsenCtrl.dispose();
    _pageCtrl.dispose();
    _cardCtrl.dispose();
    _successCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitAbsensi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    // Simulasi loading
    await Future.delayed(const Duration(milliseconds: 1400));

    setState(() {
      _isLoading = false;
      _submitted = true;
    });

    _successCtrl.forward();
    HapticFeedback.mediumImpact();
  }

  void _resetForm() {
    _successCtrl.reverse().then((_) {
      setState(() {
        _submitted = false;
        _namaCtrl.clear();
        _nomorAbsenCtrl.clear();
        _selectedKelas = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2),
      body: Stack(
        children: [
          // ── BACKGROUND DEKORASI
          Positioned(
            top: -60,
            right: -40,
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _floatAnim.value),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1D9E75).withOpacity(0.08),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: -70,
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, -_floatAnim.value * 0.6),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF534AB7).withOpacity(0.06),
                  ),
                ),
              ),
            ),
          ),

          // ── KONTEN UTAMA
          FadeTransition(
            opacity: _pageFade,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Header
                  SlideTransition(
                    position: _headerSlide,
                    child: _buildHeader(topPad),
                  ),

                  const SizedBox(height: 24),

                  // Form / Success
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _submitted
                        ? _buildSuccessCard()
                        : _buildFormCard(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPad) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
      child: Row(
        children: [
          // Ikon absensi
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _floatAnim.value * 0.3),
              child: child,
            ),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D9E75), Color(0xFF5DCAA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D9E75).withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fact_check_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Absensi Harian',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: Color(0xFF1D9E75),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _tanggalSekarang,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1D9E75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Color(0xFF888780),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _jamSekarang,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888780),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D9E75),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Aktif',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF0F6E56),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Padding(
      key: const ValueKey('form'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Info card tanggal
            _AnimatedFormItem(
              controller: _cardCtrl,
              delay: 0.0,
              child: _DateInfoCard(),
            ),

            const SizedBox(height: 14),

            // Field Nama
            _AnimatedFormItem(
              controller: _cardCtrl,
              delay: 0.15,
              child: _buildInputCard(
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkapmu',
                icon: Icons.person_rounded,
                color: const Color(0xFF1D9E75),
                bgColor: const Color(0xFFE1F5EE),
                controller: _namaCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (v.trim().length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
            ),

            const SizedBox(height: 14),

            // Field Kelas (Dropdown)
            _AnimatedFormItem(
              controller: _cardCtrl,
              delay: 0.25,
              child: _buildDropdownCard(),
            ),

            const SizedBox(height: 14),

            // Field Nomor Absen
            _AnimatedFormItem(
              controller: _cardCtrl,
              delay: 0.35,
              child: _buildInputCard(
                label: 'Nomor Absen',
                hint: 'Nomor absenmu (contoh: 15)',
                icon: Icons.tag_rounded,
                color: const Color(0xFF534AB7),
                bgColor: const Color(0xFFEEEDFE),
                controller: _nomorAbsenCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nomor absen tidak boleh kosong';
                  }
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1 || n > 40) {
                    return 'Nomor absen harus antara 1–40';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Submit
            _AnimatedFormItem(
              controller: _cardCtrl,
              delay: 0.45,
              child: _buildSubmitButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: color, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              inputFormatters: inputFormatters,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFB4B2A9),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                errorStyle: const TextStyle(fontSize: 11),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: color, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE24B4A),
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE24B4A),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBA7517).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAEEDA),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.class_rounded,
                    color: Color(0xFFBA7517),
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Kelas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBA7517),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Grid pilih kelas
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kelasList.map((kelas) {
                final isSelected = _selectedKelas == kelas;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedKelas = kelas);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFBA7517)
                          : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFBA7517)
                            : const Color(0xFFD3D1C7),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      kelas,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF444441),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_selectedKelas == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Pilih kelasmu di atas',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB4B2A9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading
                ? [const Color(0xFF5DCAA5), const Color(0xFF9FE1CB)]
                : [const Color(0xFF1D9E75), const Color(0xFF0F6E56)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D9E75).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitAbsensi,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Menyimpan absensi...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Kirim Absensi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Padding(
      key: const ValueKey('success'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Kartu sukses
          ScaleTransition(
            scale: _successScale,
            child: FadeTransition(
              opacity: _successOpacity,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D9E75).withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Ikon sukses
                    AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _floatAnim.value * 0.5),
                        child: child,
                      ),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE1F5EE),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1D9E75).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF1D9E75),
                          size: 52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Absensi Berhasil! 🎉',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kehadiranmu hari ini sudah tercatat.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888780),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFF0F4F2), height: 1),
                    const SizedBox(height: 20),

                    // Rekap data
                    _DataRow(
                      icon: Icons.person_rounded,
                      color: const Color(0xFF1D9E75),
                      bgColor: const Color(0xFFE1F5EE),
                      label: 'Nama',
                      value: _namaCtrl.text,
                    ),
                    const SizedBox(height: 12),
                    _DataRow(
                      icon: Icons.class_rounded,
                      color: const Color(0xFFBA7517),
                      bgColor: const Color(0xFFFAEEDA),
                      label: 'Kelas',
                      value: _selectedKelas ?? '-',
                    ),
                    const SizedBox(height: 12),
                    _DataRow(
                      icon: Icons.tag_rounded,
                      color: const Color(0xFF534AB7),
                      bgColor: const Color(0xFFEEEDFE),
                      label: 'No. Absen',
                      value: _nomorAbsenCtrl.text,
                    ),
                    const SizedBox(height: 12),
                    _DataRow(
                      icon: Icons.calendar_today_rounded,
                      color: const Color(0xFF378ADD),
                      bgColor: const Color(0xFFE6F1FB),
                      label: 'Tanggal',
                      value: _tanggalSekarang,
                    ),
                    const SizedBox(height: 12),
                    _DataRow(
                      icon: Icons.access_time_rounded,
                      color: const Color(0xFFD85A30),
                      bgColor: const Color(0xFFFAECE7),
                      label: 'Jam',
                      value: _jamSekarang,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tombol absensi lagi
          FadeTransition(
            opacity: _successOpacity,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF1D9E75),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF1D9E75),
                  size: 18,
                ),
                label: const Text(
                  'Absensi Ulang',
                  style: TextStyle(
                    color: Color(0xFF1D9E75),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// DATE INFO CARD
// =========================
class _DateInfoCard extends StatelessWidget {
  const _DateInfoCard();

  @override
  Widget build(BuildContext context) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const hari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final now = DateTime.now();
    final hariStr = hari[now.weekday - 1];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D9E75), Color(0xFF5DCAA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D9E75).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${now.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                Text(
                  bulan[now.month].substring(0, 3).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hariStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${now.day} ${bulan[now.month]} ${now.year}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_clock_rounded, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text(
                  'Otomatis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// DATA ROW (untuk kartu sukses)
// =========================
class _DataRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String label;
  final String value;

  const _DataRow({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF888780),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// =========================
// ANIMATED FORM ITEM
// =========================
class _AnimatedFormItem extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _AnimatedFormItem({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, c) {
        final raw = (controller.value - delay) / (1.0 - delay).clamp(0.01, 1.0);
        final t = Curves.easeOutCubic.transform(raw.clamp(0.0, 1.0));
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}