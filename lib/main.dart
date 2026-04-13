// @dart=3.0

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  // Ensure Flutter is ready before initializing Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your partner's keys
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
        useMaterial3: true, // Tells Flutter to use the latest design logic
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003A6C),
          primary: const Color(0xFF003A6C),
          surface: Colors.white,
        ),
        
        // Fix for the CardTheme error
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),

        // Fix for the 'primary' button error
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003A6C), // Changed from primary
            foregroundColor: Colors.white,            // Changed from onPrimary
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
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

  // --- ADD THIS NEW LISTENER BLOCK ---
  @override
  void initState() {
    super.initState();
    // This listens for Google sending you back with a success token
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    });
  }

  // Standard Email/Password Login
  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // SUCCESS! Kill the loading spinner and navigate to the Dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Google OAuth Login (for Web)
  Future<void> _googleSignIn() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:3000', // <-- ADD THIS LINE!
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. The Full-Screen Background Photo
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF003A6C),
              image: DecorationImage(
                image: const AssetImage('assets/login_bg.jpg'), // Ensure this matches your filename!
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color(0xFF003A6C).withOpacity(0.4), 
                  BlendMode.darken
                ),
              ),
            ),
          ),

          // 2. The Branding Text (Top Left)
          Positioned(
            top: 60,
            left: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clinic Control',
                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'ADDU HEALTH SERVICES',
                  style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 2),
                ),
              ],
            ),
          ),

          // 3. The Floating Login Card (Right Side)
          Align(
            alignment: const Alignment(0.6, 0), // Positions it slightly to the right
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24), // Large rounded corners like the ref
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Sign In', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Use your staff credentials to continue.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  
                  // Email Field
                  TextField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next, // Shows "Next" on mobile keyboards
                    decoration: const InputDecoration(
                      labelText: 'Email', 
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(), // Moves to password
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done, // Shows "Done/Enter" on keyboard
                    decoration: const InputDecoration(
                      labelText: 'Password', 
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    // THIS IS THE MAGIC LINE:
                    onSubmitted: (_) => _isLoading ? null : _signIn(), 
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Google Button
                  OutlinedButton.icon(
                    onPressed: _googleSignIn,
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
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

// --- Make sure this part is here! ---
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<dynamic>> _dashboardData;
  String _adminName = 'Loading...'; 
  List<dynamic> _students = []; // <-- NEW: Holds our student list for the dropdown
  
  int _selectedIndex = 0; 
  String _searchQuery = '';
  
  final _nameController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _dashboardData = _fetchConsultations();
    _fetchAdminProfile(); 
    _fetchStudentsList(); // <-- NEW: Load the students right away!
  }

  // --- NEW: Get all students for our dropdown menu ---
  Future<void> _fetchStudentsList() async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name')
          .eq('role', 'student')
          .order('full_name');
      if (mounted) setState(() => _students = response as List<dynamic>);
    } catch (e) {
      debugPrint('Error fetching students: $e');
    }
  }

  Future<List<dynamic>> _fetchConsultations() async {
    final response = await Supabase.instance.client
        .from('consultations')
        // We added 'id' and 'student_id' at the very beginning!
        .select('id, student_id, consultation_date, complaint, diagnosis, attending_staff, profiles(full_name), medications_dispensed(med_name, dosage, quantity), medical_certificates(file_url)')
        .order('consultation_date', ascending: false);
    return response as List<dynamic>;
  }

  Future<void> _fetchAdminProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .single(); 
        
        if (mounted) {
          setState(() {
            _adminName = response['full_name'] ?? 'Admin User';
            _nameController.text = _adminName;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _adminName = 'Clinic Staff');
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isUpdating = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({'full_name': _nameController.text.trim()})
            .eq('id', user.id);
            
        setState(() => _adminName = _nameController.text.trim());
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  // --- NEW: The "Create Data" Form ---
  void _showCreateConsultationDialog() {
    String? selectedStudentId;
    final complaintController = TextEditingController();
    final diagnosisController = TextEditingController();
    
    // New Medication Fields
    final medNameController = TextEditingController();
    final medDosageController = TextEditingController();
    final medQtyController = TextEditingController();
    
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
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Patient Info', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003A6C))),
                    const Divider(),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Select Student'),
                      value: selectedStudentId,
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
                    TextField(controller: medNameController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Medication Name (e.g., Paracetamol)')),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: medDosageController, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Dosage (e.g., 500mg)'))),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(controller: medQtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Quantity (e.g., 2)'))),
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
                  
                  try {
                    // 1. Insert Consultation AND ask Supabase to return the new ID
                    final consultResponse = await Supabase.instance.client.from('consultations').insert({
                      'student_id': selectedStudentId,
                      'complaint': complaintController.text.trim(),
                      'diagnosis': diagnosisController.text.trim().isEmpty ? 'Pending' : diagnosisController.text.trim(),
                      'attending_staff': _adminName,
                      'consultation_date': DateTime.now().toIso8601String(),
                    }).select('id').single(); // <-- The magic command to get the ID back!

                    final newConsultId = consultResponse['id'];

                    // 2. If they typed a medication, insert it using the new ID!
                    if (medNameController.text.isNotEmpty) {
                      await Supabase.instance.client.from('medications_dispensed').insert({
                        'consultation_id': newConsultId, // Links it to the consultation
                        'student_id': selectedStudentId, // Links it to the student
                        'med_name': medNameController.text.trim(),
                        'dosage': medDosageController.text.trim().isEmpty ? 'N/A' : medDosageController.text.trim(),
                        'quantity': int.tryParse(medQtyController.text.trim()) ?? 1,
                      });
                    }

                    if (mounted) {
                      Navigator.pop(context);
                      setState(() => _dashboardData = _fetchConsultations()); 
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consultation recorded!'), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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

// --- NEW: The Update Record Form ---
  void _showUpdateDialog(Map<String, dynamic> record) {
    final diagnosisController = TextEditingController(text: record['diagnosis']);
    bool isSaving = false; // Now we are going to use this!

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Update Diagnosis', style: TextStyle(color: Color(0xFF003A6C), fontWeight: FontWeight.bold)),
            content: TextField(
              controller: diagnosisController,
              decoration: const InputDecoration(labelText: 'Final Diagnosis', border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context), 
                child: const Text('Cancel')
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003A6C)),
                onPressed: isSaving ? null : () async {
                  // 1. Start loading
                  setDialogState(() => isSaving = true);
                  
                  try {
                    // 2. Actually update the database
                    await Supabase.instance.client
                        .from('consultations')
                        .update({'diagnosis': diagnosisController.text.trim()})
                        .eq('id', record['id']);
                    
                    if (mounted) {
                      Navigator.pop(context); // Close this dialog
                      Navigator.pop(context); // Close the details popup behind it
                      setState(() {
                        _dashboardData = _fetchConsultations(); // Refresh the table
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Record updated!'), backgroundColor: Colors.green)
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
                      );
                    }
                  } finally {
                    // 3. Stop loading
                    if (mounted) setDialogState(() => isSaving = false);
                  }
                },
                child: isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

 // --- UPGRADED POPUP: With Meds, Certs, AND the Update Button! ---
  void _showDetailsDialog(Map<String, dynamic> record, String studentName, String displayDate) {
    // Safely extract the new data lists
    final List<dynamic> meds = record['medications_dispensed'] ?? [];
    final List<dynamic> certs = record['medical_certificates'] ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                
                // --- Medications Section ---
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

                // --- Medical Certificate Section ---
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
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the file link.'), backgroundColor: Colors.red));
                          }
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No valid file URL found.')));
                        }
                      }
                    }, 
                    icon: const Icon(Icons.file_download, color: Color(0xFF003A6C)), 
                    label: const Text('View Medical Certificate', style: TextStyle(color: Color(0xFF003A6C))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF003A6C)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003A6C)),
            onPressed: () {
               // This launches the update form!
               _showUpdateDialog(record); 
            },
            child: const Text('Update Record'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- NEW: The Floating Action Button! ---
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton.extended(
            onPressed: _showCreateConsultationDialog,
            backgroundColor: const Color(0xFF003A6C),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Consultation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        : null, // Hides the button when you go to "My Account"
      
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
                    _adminName != 'Loading...' ? _adminName[0].toUpperCase() : '?', 
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
                  selectedTileColor: Colors.white.withOpacity(0.1),
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                ListTile(
                  leading: Icon(Icons.person_outline, color: _selectedIndex == 1 ? Colors.white : Colors.white70),
                  title: Text('My Account', style: TextStyle(color: _selectedIndex == 1 ? Colors.white : Colors.white70)),
                  selectedTileColor: Colors.white.withOpacity(0.1),
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white70),
                  title: const Text('Logout', style: TextStyle(color: Colors.white70)),
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AdminLoginScreen()));
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
                      headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) => Colors.grey.shade100),
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
                            if (states.contains(WidgetState.hovered)) return Colors.blue.shade50; // Lights up on hover!
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Account Settings', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        SizedBox(
          width: 500,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Profile Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(height: 32),
                  const Text('Display Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(controller: _nameController, decoration: const InputDecoration(prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _updateProfile,
                      child: _isUpdating 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save Changes'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}