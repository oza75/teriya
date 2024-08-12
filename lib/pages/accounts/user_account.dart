import 'package:Teriya/services/auth_service.dart';
import 'package:Teriya/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserAccount extends StatelessWidget {
  const UserAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Account"),
      ),
      body: SafeArea(
        child: Material(
          color: platformScaffoldBackgroundColor(context),
          child: ListView(
            children: [
              _buildSectionHeader('Details'),
              _buildListTile('Name', user.fullName),
              _buildListTile('Email', user.email),
              ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Provider.of<AuthService>(context, listen: false)
                      .logout()
                      .then((_) {
                    context.goNamed("welcome");
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
