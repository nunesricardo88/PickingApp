import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class LoadingDisplay extends StatelessWidget {
  final bool isLoading;
  final String loadingText;
  final Widget child;

  const LoadingDisplay({
    required this.isLoading,
    required this.loadingText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      color: Colors.black,
      opacity: 0.4,
      isLoading: isLoading,
      progressIndicator: Card(
        color: kWhiteBackground,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 50.0),
                child: const SpinKitFadingCube(
                  color: kPrimaryColor,
                  size: 35.0,
                ),
              ),
              const SizedBox(
                height: 35.0,
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 200.0),
                child: Text(
                  loadingText.isEmpty ? 'Por favor, aguarde' : loadingText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: kPrimaryColor,
                        fontSize: 16.0,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
      child: child,
    );
  }
}
