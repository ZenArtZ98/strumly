import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strumly/features/auth/domain/entities/user_profile.dart';
import 'dart:io';
import '../blocs/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({Key? key, required this.userProfile}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController descriptionController = TextEditingController();
  String? avatarPath;

  @override
  void initState() {
    super.initState();
    descriptionController.text = widget.userProfile.description;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        avatarPath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final updatedProfile = UserProfile(
                uid: widget.userProfile.uid,
                username: widget.userProfile.username,
                description: descriptionController.text,
                avatarUrl: avatarPath ?? widget.userProfile.avatarUrl ?? '', // Убедитесь, что avatarUrl не null
                activityData: widget.userProfile.activityData,
                stats: widget.userProfile.stats,
              );
              context.read<ProfileBloc>().add(UpdateProfileEvent(updatedProfile));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: avatarPath != null
                    ? FileImage(File(avatarPath!))
                    : (widget.userProfile.avatarUrl != null && widget.userProfile.avatarUrl!.isNotEmpty
                    ? NetworkImage(widget.userProfile.avatarUrl!)
                    : const AssetImage('assets/default_avatar.png')) as ImageProvider,
                child: avatarPath == null ? const Icon(Icons.add_a_photo) : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
          ],
        ),
      ),
    );
  }
}
