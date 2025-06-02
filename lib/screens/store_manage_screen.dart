import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class StoreManageScreen extends StatefulWidget {
  final String jwtToken;
  final String storeId;
  const StoreManageScreen(
      {super.key, required this.jwtToken, required this.storeId});
  @override
  State<StoreManageScreen> createState() => _StoreManageScreenState();
}

class _StoreManageScreenState extends State<StoreManageScreen> {
  Map<String, dynamic>? storeInfo;
  List<Map<String, dynamic>> members = [];
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    final info = await SupabaseService.getStoreInfoRest(
      token: widget.jwtToken,
      storeId: widget.storeId,
    );
    final mems = await SupabaseService.getStoreMembersRest(
      token: widget.jwtToken,
      storeId: widget.storeId,
    );
    setState(() {
      storeInfo = info;
      members = mems;
      nameController.text = info['name'] ?? '';
      addressController.text = info['address'] ?? '';
      contactController.text = info['contact'] ?? '';
    });
  }

  Future<void> saveStoreInfo() async {
    await SupabaseService.updateStoreInfoRest(
      token: widget.jwtToken,
      storeId: widget.storeId,
      update: {
        'name': nameController.text,
        'address': addressController.text,
        'contact': contactController.text,
      },
    );
    await loadAll();
  }

  Future<void> inviteMember(String email, String role) async {
    await SupabaseService.inviteMemberRest(
      token: widget.jwtToken,
      storeId: widget.storeId,
      email: email,
      role: role,
    );
    await loadAll();
  }

  Future<void> updateRole(String memberId, String role) async {
    await SupabaseService.updateMemberRoleRest(
      token: widget.jwtToken,
      storeId: widget.storeId,
      memberId: memberId,
      role: role,
    );
    await loadAll();
  }

  Future<void> removeMember(String memberId) async {
    await SupabaseService.removeMemberRest(
      token: widget.jwtToken,
      storeId: widget.storeId,
      memberId: memberId,
    );
    await loadAll();
  }

  @override
  Widget build(BuildContext context) {
    if (storeInfo == null)
      return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text('매장/직원 관리')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('매장 정보', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '매장명')),
            TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: '주소')),
            TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: '연락처')),
            ElevatedButton(onPressed: saveStoreInfo, child: const Text('저장')),
            const SizedBox(height: 24),
            const Text('직원 목록', style: TextStyle(fontWeight: FontWeight.bold)),
            ...members.map((m) => ListTile(
                  title: Text('${m['name'] ?? m['email']}'),
                  subtitle: Text('역할: ${m['role']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: m['role'],
                        items: const [
                          DropdownMenuItem(value: 'owner', child: Text('오너')),
                          DropdownMenuItem(
                              value: 'manager', child: Text('매니저')),
                          DropdownMenuItem(value: 'cashier', child: Text('캐셔')),
                        ],
                        onChanged: (role) {
                          if (role != null && role != m['role']) {
                            updateRole(m['id'], role);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => removeMember(m['id']),
                      ),
                    ],
                  ),
                )),
            const Divider(),
            const Text('직원 초대', style: TextStyle(fontWeight: FontWeight.bold)),
            _InviteMemberWidget(onInvite: inviteMember),
          ],
        ),
      ),
    );
  }
}

class _InviteMemberWidget extends StatefulWidget {
  final Future<void> Function(String email, String role) onInvite;
  const _InviteMemberWidget({required this.onInvite});
  @override
  State<_InviteMemberWidget> createState() => _InviteMemberWidgetState();
}

class _InviteMemberWidgetState extends State<_InviteMemberWidget> {
  final emailController = TextEditingController();
  String role = 'cashier';
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: '이메일'))),
        DropdownButton<String>(
          value: role,
          items: const [
            DropdownMenuItem(value: 'manager', child: Text('매니저')),
            DropdownMenuItem(value: 'cashier', child: Text('캐셔')),
          ],
          onChanged: (v) => setState(() => role = v!),
        ),
        ElevatedButton(
          onPressed: () => widget.onInvite(emailController.text, role),
          child: const Text('초대'),
        ),
      ],
    );
  }
}
