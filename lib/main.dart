// @dart=3.0
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart'; // <-- NEW PACKAGE!

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hapyyuyfdvgxyyomtlzs.supabase.co',
    anonKey: 'sb_publishable_slBMRFhuREJKxmyNamnglg_U2Qb2Hxo',
  );

  runApp(const ClinicDashboardApp());
}

class ClinicDashboardApp extends StatelessWidget {
  const ClinicDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic Control Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003A6C),
          primary: const Color(0xFF003A6C),
          surface: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003A6C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF003A6C), width: 2),
          ),
        ),
      ),
      home: const AdminLoginScreen(), 
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DashboardScreen()));
      }
    });
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
      navigator.pushReplacement(MaterialPageRoute(builder: (context) => const DashboardScreen()));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google, redirectTo: 'http://localhost:3000');
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Google Sign-In Error: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF003A6C),
              image: DecorationImage(
                image: const AssetImage('assets/login_bg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(const Color(0xFF003A6C).withValues(alpha: 0.4), BlendMode.darken),
              ),
            ),
          ),
          Positioned(
            top: 60, left: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Clinic Control', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                Text('ADDU HEALTH SERVICES', style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 2)),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(0.6, 0),
            child: Container(
              width: 450, padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Sign In', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Use your staff credentials to continue.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController, textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(), 
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController, obscureText: true, textInputAction: TextInputAction.done, 
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                    onSubmitted: (_) => _isLoading ? null : _signIn(), 
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _googleSignIn, icon: const Icon(Icons.login), label: const Text('Sign in with Google'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<dynamic>> _dashboardData;
  String _adminName = 'Loading...'; 
  String _adminEmail = 'Loading...';
  String _adminRole = 'Loading...';  
  List<dynamic> _students = []; 
  
  int _selectedIndex = 0; 
  String _searchQuery = '';
  
  final _nameController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _dashboardData = _fetchConsultations();
    _fetchAdminProfile(); 
    _fetchStudentsList(); 
  }

  Future<void> _fetchStudentsList() async {
    try {
      final response = await Supabase.instance.client.from('profiles').select('id, full_name').eq('role', 'student').order('full_name');
      if (mounted) setState(() => _students = response as List<dynamic>);
    } catch (e) {
      debugPrint('Error fetching students: $e');
    }
  }

  Future<List<dynamic>> _fetchConsultations() async {
    final response = await Supabase.instance.client
        .from('consultations')
        // UPDATED: Grabbed ID for meds and certs so we can update them later
        .select('id, student_id, consultation_date, complaint, diagnosis, attending_staff, profiles(full_name), medications_dispensed(id, med_name, dosage, quantity), medical_certificates(id, file_url)')
        .order('consultation_date', ascending: false);
    return response as List<dynamic>;
  }

  Future<void> _fetchAdminProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client.from('profiles').select('full_name, role').eq('id', user.id).single(); 
        if (mounted) {
          setState(() {
            _adminName = response['full_name'] ?? 'Admin User';
            _nameController.text = _adminName;
            _adminRole = (response['role'] ?? 'Unassigned').toString().toUpperCase();
            _adminEmail = user.email ?? 'No email linked';
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() { _adminName = 'Clinic Staff'; _adminRole = 'STAFF'; });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isUpdating = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').update({'full_name': _nameController.text.trim()}).eq('id', user.id);
        setState(() => _adminName = _nameController.text.trim());
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // --- UPLOAD HELPER METHOD ---
  // --- UPLOAD HELPER METHOD (Upgraded for Error Tracking) ---
  // --- UPLOAD HELPER METHOD (Upgraded with File Sanitization) ---
  Future<String?> _uploadCertificate(PlatformFile file, String studentId) async {
    if (file.bytes == null) {
      throw Exception("The file data is empty. Please try selecting the file again.");
    }
    
    // THE FIX: Clean the filename! Removes ñ, commas, spaces, etc.
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9\.\-]'), '_');
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final filePath = '$studentId/$fileName'; 
    
    await Supabase.instance.client.storage.from('certificates').uploadBinary(filePath, file.bytes!);
    return Supabase.instance.client.storage.from('certificates').getPublicUrl(filePath);
  }

  void _showCreateConsultationDialog() {
    String? selectedStudentId;
    final complaintController = TextEditingController();
    final diagnosisController = TextEditingController();
    final medNameController = TextEditingController();
    final medDosageController = TextEditingController();
    final medQtyController = TextEditingController();
    
    PlatformFile? selectedFile; 
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('New Consultation', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003A6C))),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Select Student'),
                      initialValue: selectedStudentId,
                      items: _students.map((s) => DropdownMenuItem<String>(value: s['id'], child: Text(s['full_name'] ?? 'Unknown'))).toList(),
                      onChanged: (val) => setDialogState(() => selectedStudentId = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: complaintController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Chief Complaint')),
                    const SizedBox(height: 16),
                    TextField(controller: diagnosisController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Initial Diagnosis (Optional)')),
                    const SizedBox(height: 32),
                    
                    const Text('Dispense Medication (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003A6C))),
                    const Divider(),
                    TextField(controller: medNameController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Medication Name (e.g. Paracetamol)')),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: medDosageController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Dosage'))),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(controller: medQtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Quantity'))),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- FILE UPLOAD SECTION ---
                    const Text('Medical Certificate (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003A6C))),
                    const Divider(),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.pickFiles(
                              type: FileType.custom, 
                              allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                              withData: true, // <--- ADD THIS MAGIC LINE!
                            );
                            if (result != null) setDialogState(() => selectedFile = result.files.first);
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Choose File'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Text(selectedFile?.name ?? 'No file selected', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: isSaving ? null : () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003A6C)),
                onPressed: isSaving ? null : () async {
                  if (selectedStudentId == null || complaintController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a student and enter a complaint.')));
                    return;
                  }
                  
                  setDialogState(() => isSaving = true);
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  
                  try {
                    // 1. Insert Consultation
                    final consultResponse = await Supabase.instance.client.from('consultations').insert({
                      'student_id': selectedStudentId,
                      'complaint': complaintController.text.trim(),
                      'diagnosis': diagnosisController.text.trim().isEmpty ? 'Pending' : diagnosisController.text.trim(),
                      'attending_staff': _adminName,
                      'consultation_date': DateTime.now().toIso8601String(),
                    }).select('id').single(); 

                    final newConsultId = consultResponse['id'];

                    // 2. Insert Medication
                    if (medNameController.text.isNotEmpty) {
                      await Supabase.instance.client.from('medications_dispensed').insert({
                        'consultation_id': newConsultId, 
                        'student_id': selectedStudentId, 
                        'med_name': medNameController.text.trim(),
                        'dosage': medDosageController.text.trim().isEmpty ? 'N/A' : medDosageController.text.trim(),
                        'quantity': int.tryParse(medQtyController.text.trim()) ?? 1,
                      });
                    }

                    // 3. Upload & Insert Certificate
                    if (selectedFile != null) {
                      final publicUrl = await _uploadCertificate(selectedFile!, selectedStudentId!);
                      if (publicUrl != null) {
                        await Supabase.instance.client.from('medical_certificates').insert({
                          'consultation_id': newConsultId,
                          'student_id': selectedStudentId,
                          'file_url': publicUrl,
                        });
                      }
                    }

                    navigator.pop();
                    setState(() => _dashboardData = _fetchConsultations()); 
                    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Consultation recorded!'), backgroundColor: Colors.green));
                    
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                  } finally {
                    setDialogState(() => isSaving = false);
                  }
                },
                child: isSaving ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Record'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showUpdateDialog(Map<String, dynamic> record) {
    final diagnosisController = TextEditingController(text: record['diagnosis']);
    
    // Extract existing med details if they exist
    final List<dynamic> meds = record['medications_dispensed'] ?? [];
    final String? existingMedId = meds.isNotEmpty ? meds[0]['id'] : null;
    final medNameController = TextEditingController(text: meds.isNotEmpty ? meds[0]['med_name'] : '');
    final medDosageController = TextEditingController(text: meds.isNotEmpty ? meds[0]['dosage'] : '');
    final medQtyController = TextEditingController(text: meds.isNotEmpty ? meds[0]['quantity'].toString() : '');

    PlatformFile? selectedFile;
    bool isSaving = false; 

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('Update Medical Record', style: TextStyle(color: Color(0xFF003A6C), fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Diagnosis', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003A6C))),
                    const SizedBox(height: 8),
                    TextField(controller: diagnosisController, decoration: const InputDecoration(labelText: 'Final Diagnosis', border: OutlineInputBorder())),
                    const SizedBox(height: 24),

                    const Text('Update Medications', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003A6C))),
                    const Divider(),
                    TextField(controller: medNameController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Medication Name')),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: medDosageController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Dosage'))),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(controller: medQtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Quantity'))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text('Attach New Certificate', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003A6C))),
                    const Divider(),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.pickFiles(
                              type: FileType.custom, 
                              allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                              withData: true, // <--- ADD THIS MAGIC LINE!
                            );
                            if (result != null) setDialogState(() => selectedFile = result.files.first);
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Choose File'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Text(selectedFile?.name ?? 'No new file selected', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: isSaving ? null : () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003A6C)),
                onPressed: isSaving ? null : () {
                  // --- SHOW THE STRICT WARNING CONFIRMATION ---
                  showDialog(
                    context: context,
                    builder: (confirmContext) => AlertDialog(
                      title: const Text('⚠️ Confirm Update', style: TextStyle(color: Color(0xFF003A6C), fontWeight: FontWeight.bold)),
                      content: const Text('Are you sure these medical details and dispensed medications are correct?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(confirmContext), child: const Text('Review Again')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003A6C)),
                          onPressed: () async {
                            Navigator.pop(confirmContext); // Close warning
                            setDialogState(() => isSaving = true);
                            
                            final navigator = Navigator.of(context);
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            
                            try {
                              // 1. Update Diagnosis
                              await Supabase.instance.client.from('consultations')
                                  .update({'diagnosis': diagnosisController.text.trim()}).eq('id', record['id']);
                              
                              // 2. Update or Insert Medication
                              if (medNameController.text.isNotEmpty) {
                                if (existingMedId != null) {
                                  await Supabase.instance.client.from('medications_dispensed').update({
                                    'med_name': medNameController.text.trim(),
                                    'dosage': medDosageController.text.trim(),
                                    'quantity': int.tryParse(medQtyController.text.trim()) ?? 1,
                                  }).eq('id', existingMedId);
                                } else {
                                  await Supabase.instance.client.from('medications_dispensed').insert({
                                    'consultation_id': record['id'],
                                    'student_id': record['student_id'],
                                    'med_name': medNameController.text.trim(),
                                    'dosage': medDosageController.text.trim(),
                                    'quantity': int.tryParse(medQtyController.text.trim()) ?? 1,
                                  });
                                }
                              }

                              // 3. Upload new file if added
                              if (selectedFile != null) {
                                final publicUrl = await _uploadCertificate(selectedFile!, record['student_id']);
                                if (publicUrl != null) {
                                  await Supabase.instance.client.from('medical_certificates').insert({
                                    'consultation_id': record['id'],
                                    'student_id': record['student_id'],
                                    'file_url': publicUrl,
                                  });
                                }
                              }
                              
                              navigator.pop(); // Close update form
                              navigator.pop(); // Close details popup
                              setState(() => _dashboardData = _fetchConsultations()); 
                              scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Record updated successfully!'), backgroundColor: Colors.green));
                              
                            } catch (e) {
                              scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                            } finally {
                              setDialogState(() => isSaving = false);
                            }
                          },
                          child: const Text('Yes, Save Changes'),
                        )
                      ]
                    )
                  );
                },
                child: isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Changes'),
              ),
            ],
          );
        }
      ),
    );
  }

  // --- SECURE DELETE CONFIRMATION ---
  void _confirmDelete(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ WARNING', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('ARE YOU SURE YOU WANT TO DELETE THIS MEDICAL RECORD? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await Supabase.instance.client.from('consultations').delete().eq('id', record['id']);
                navigator.pop(); // close warning
                navigator.pop(); // close details dialog
                setState(() => _dashboardData = _fetchConsultations());
                scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Record deleted.'), backgroundColor: Colors.red));
              } catch (e) {
                scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('DELETE'),
          )
        ]
      )
    );
  }

  void _showDetailsDialog(Map<String, dynamic> record, String studentName, String displayDate) {
    // Safety check just in case Supabase sends a Map instead of a List
    List<dynamic> _safeList(dynamic item) {
      if (item == null) return [];
      if (item is List) return item;
      return [item];
    }
    
    final List<dynamic> meds = _safeList(record['medications_dispensed']);
    final List<dynamic> certs = _safeList(record['medical_certificates']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // --- THIS FIXES THE CRASH: Pushes the delete button left, and the others right ---
        actionsAlignment: MainAxisAlignment.spaceBetween, 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Medical Record', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003A6C))),
            Chip(
              label: Text(record['diagnosis'] ?? 'Pending', style: const TextStyle(fontSize: 12, color: Color(0xFF003A6C))),
              backgroundColor: Colors.blue.shade50,
            )
          ],
        ),
        content: SizedBox(
          width: 450, 
          child: SingleChildScrollView( 
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: Color(0xFF003A6C), child: Icon(Icons.person, color: Colors.white)),
                  title: Text('Date: $displayDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(studentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                const Divider(height: 32),
                
                const Text('Chief Complaint', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(record['complaint'] ?? 'No complaint recorded.', style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 24),
                
                const Text('Medications Dispensed', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (meds.isEmpty) 
                  const Text('No medications dispensed during this visit.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
                else
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: meds.map((med) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.medication, color: Color(0xFF003A6C), size: 20),
                        title: Text('${med['med_name']} (${med['dosage']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text('Qty: ${med['quantity']}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      )).toList(),
                    ),
                  ),
                
                const SizedBox(height: 24),

                if (certs.isNotEmpty) ...[
                  const Text('Documents', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final String? urlString = certs[0]['file_url'];
                      if (urlString != null && urlString.isNotEmpty) {
                        final Uri url = Uri.parse(urlString);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication); 
                        } else {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the file link.'), backgroundColor: Colors.red));
                        }
                      } else {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No valid file URL found.')));
                      }
                    }, 
                    icon: const Icon(Icons.file_download, color: Color(0xFF003A6C)), 
                    label: const Text('View Medical Certificate', style: TextStyle(color: Color(0xFF003A6C))),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF003A6C)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(height: 24),
                ],
                
                Row(
                  children: [
                    const Icon(Icons.badge, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Attending: ${record['attending_staff'] ?? 'Unassigned'}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
          ),
        ),
        actions: [
          // 1. The Dangerous Delete Button (Left Side)
          TextButton.icon(
            onPressed: () => _confirmDelete(record),
            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
            label: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          
          // 2. The Safe Actions (Right Side)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003A6C)),
                onPressed: () => _showUpdateDialog(record),
                child: const Text('Update Record'),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton.extended(
            onPressed: _showCreateConsultationDialog,
            backgroundColor: const Color(0xFF003A6C),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Consultation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        : null, 
      
      body: Row(
        children: [
          Container(
            width: 250,
            color: const Color(0xFF003A6C),
            child: Column(
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    _adminName != 'Loading...' && _adminName.isNotEmpty ? _adminName[0].toUpperCase() : '?', 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF003A6C))
                  ),
                ),
                const SizedBox(height: 16),
                Text(_adminName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Administrator', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 48),
                
                ListTile(
                  leading: Icon(Icons.medical_services, color: _selectedIndex == 0 ? Colors.white : Colors.white70),
                  title: Text('Consultations', style: TextStyle(color: _selectedIndex == 0 ? Colors.white : Colors.white70)),
                  selectedTileColor: Colors.white.withValues(alpha: 0.1),
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                ListTile(
                  leading: Icon(Icons.person_outline, color: _selectedIndex == 1 ? Colors.white : Colors.white70),
                  title: Text('My Account', style: TextStyle(color: _selectedIndex == 1 ? Colors.white : Colors.white70)),
                  selectedTileColor: Colors.white.withValues(alpha: 0.1),
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white70),
                  title: const Text('Logout', style: TextStyle(color: Colors.white70)),
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (mounted && context.mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminLoginScreen()));
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: _selectedIndex == 0 ? _buildConsultationsView() : _buildMyAccountView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Consultations', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        SizedBox(
          width: 400, 
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search patients or complaints...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0), 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF003A6C), width: 2)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: Card(
            child: FutureBuilder<List<dynamic>>(
              future: _dashboardData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                
                final allRecords = snapshot.data;
                if (allRecords == null || allRecords.isEmpty) return const Center(child: Text('No consultations found.'));
                
                final records = allRecords.where((record) {
                  final studentName = (record['profiles'] != null ? record['profiles']['full_name'] : '').toString().toLowerCase();
                  final complaint = (record['complaint'] ?? '').toString().toLowerCase();
                  final query = _searchQuery.toLowerCase();
                  return studentName.contains(query) || complaint.contains(query);
                }).toList();

                if (records.isEmpty) return const Center(child: Text('No matching records found.', style: TextStyle(color: Colors.grey)));
                
                return SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      showCheckboxColumn: false,
                      headingRowColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) => Colors.grey.shade100),
                      columns: const [
                        DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Patient Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Diagnosis', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: records.map((record) {
                        final dateStr = record['consultation_date'] ?? '';
                        final displayDate = dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr;
                        final studentName = record['profiles'] != null ? record['profiles']['full_name'] : 'Unknown Student';

                        return DataRow(
                          onSelectChanged: (selected) => _showDetailsDialog(record, studentName, displayDate),
                          color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered)) return Colors.blue.shade50; 
                            return null; 
                          }),
                          cells: [
                            DataCell(Text(displayDate)),
                            DataCell(Text(studentName, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(record['diagnosis'] ?? 'Pending')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyAccountView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(
            width: 600, 
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF003A6C).withValues(alpha: 0.1),
                          child: Text(
                            _adminName != 'Loading...' && _adminName.isNotEmpty ? _adminName[0].toUpperCase() : '?', 
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF003A6C))
                          ),
                        ),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_adminName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF003A6C), borderRadius: BorderRadius.circular(100)),
                              child: Text(_adminRole, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          ],
                        )
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),

                    const Text('Account Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),

                    const Text('Registered Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: _adminEmail),
                      readOnly: true, style: const TextStyle(color: Colors.grey), 
                      decoration: InputDecoration(prefixIcon: const Icon(Icons.email, color: Colors.grey), fillColor: Colors.grey.shade100)
                    ),
                    const SizedBox(height: 24),

                    const Text('Display Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController, 
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.person, color: Color(0xFF003A6C)), hintText: 'Enter your full name')
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003A6C)),
                        onPressed: _isUpdating ? null : _updateProfile,
                        icon: _isUpdating ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save, size: 18, color: Colors.white,),
                        label: Text(_isUpdating ? 'Saving...' : 'Save Changes', style: const TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}