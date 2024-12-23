import 'package:ahealth/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/initialized/init_app_cubit.dart';
import '../../common/spring_button_widget.dart';

class SdkErrorScreen extends StatelessWidget {
  const SdkErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: kToolbarHeight),
          Text(
            'SDK Unavailable',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'SDK is unavailable. Please install heath connect app',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
            SpringButton(
              SpringButtonType.onlyScale,
              onTap: () async =>
                  await context.read<InitAppCubit>().installHealthConnect(),
              uiChild: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: primary,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Download Health SDK",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: white,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
