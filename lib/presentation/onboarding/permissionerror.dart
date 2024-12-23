import 'package:ahealth/appcolors.dart';
import 'package:ahealth/common/spring_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/initialized/init_app_cubit.dart';

class PermissionErrorScreem extends StatelessWidget {
  const PermissionErrorScreem({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight),
            Text(
              'Permission Error',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Required permissions are not Found',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Why?\n',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children:  <TextSpan>[
                  TextSpan(
                    text: 'Your Privacy Matters.\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text: 'We prioritize your privacy and data security.\n\n',
                  ),
                  TextSpan(
                    text: 'No Data Storage:\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'Your personal data will **not** be stored on our servers.\n\n',
                  ),
                  TextSpan(
                    text: 'Data Usage:\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'Your data is solely used for the purpose of calculating your overall health score.\n',
                  ),
                  const TextSpan(
                    text:
                        'The calculated score is then presented to you in a visually understandable format.\n\n',
                  ),
                  TextSpan(
                    text: 'Transparency:\n',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'We are transparent about how your data is used and ensure your privacy is protected.',
                  ),
                ],
              ),
            ),
            const Spacer(),
            SpringButton(
              SpringButtonType.onlyScale,
              onTap: () async =>
                  await context.read<InitAppCubit>().checkPermissions(),
              uiChild: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: primary,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Take Permmision",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: white,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
