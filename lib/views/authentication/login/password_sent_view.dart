import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_colors.dart';
import '../../constants/strings.dart';

class PasswordSentView extends StatelessWidget {
  const PasswordSentView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 24),
                      Text(
                        Strings.resetEmailSent,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: Text(
                            Strings.toFrontPage,
                            style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}