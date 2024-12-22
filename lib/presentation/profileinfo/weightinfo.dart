import 'package:ahealth/appcolors.dart';
import 'package:ahealth/common/spring_button_widget.dart';
import 'package:ahealth/presentation/home.dart';
import 'package:ahealth/presentation/profileinfo/rularslider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum HeightUnit { cm, ft }

enum WeightUnit { kg, lbs }

enum Gender { male, female, other, preferNotToSay }

enum HealthGoal {
  lossWeight,
  gainWeight,
  maintainWeight,
  gainMuscle,
  lifeStyleImprove
}

class HeathDetailScreen extends StatefulWidget {
  const HeathDetailScreen({super.key});

  @override
  State<HeathDetailScreen> createState() => _HeathDetailScreenState();
}

class _HeathDetailScreenState extends State<HeathDetailScreen> {
  int step = 1; // 5 = 50%
  // Initially, the first button is selected

  Gender selectedGender = Gender.male;
  HealthGoal selectedHealthGoal = HealthGoal.lifeStyleImprove;

  final TextEditingController wightTextEditingController =
      TextEditingController();
  double initialWeightValue = 50.0;
  WeightUnit weightUnit = WeightUnit.kg;

  final TextEditingController heightTextEditingController =
      TextEditingController();
  double initialHeightValue = 150.0;
  HeightUnit heightUnit = HeightUnit.cm;

  int age = 24;

  @override
  void initState() {
    super.initState();
    wightTextEditingController.text = initialWeightValue.toStringAsFixed(1);
    heightTextEditingController.text = initialHeightValue.toStringAsFixed(1);
  }

  @override
  void dispose() {
    wightTextEditingController.dispose();
    heightTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: (step == 1),
      onPopInvokedWithResult: (didPop, result) async {
        if (step > 1) {
          setState(() {
            step--;
          });
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              if (step > 1) {
                setState(() {
                  step--;
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 16, top: 16),
              child: SvgPicture.asset(
                'assets/icons/back.svg',
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Stack(
            children: [
              Container(
                width: 150,
                height: 8,
                decoration: BoxDecoration(
                  color: grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 15 * 2 * step.toDouble(),
                height: 8,
                decoration: BoxDecoration(
                  color: black,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text(
                "Skip",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          // child: height(context),
          child: (step == 1)
              ? weight(context)
              : (step == 2)
                  ? height(context)
                  : (step == 3)
                      ? genderWidget(context)
                      : (step == 4)
                          ? healthGoalWidget(context)
                          : ageWidget(context),
        ),
      ),
    );
  }

  /// section weight => step 1
  Column weight(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: kToolbarHeight),
        Text(
          'What is your Weight?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: kToolbarHeight),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SpringButton(
              SpringButtonType.onlyScale,
              onTap: () {
                setState(() {
                  weightUnit = WeightUnit.kg;
                });
              },
              uiChild: Container(
                width: 156,
                height: 52,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (weightUnit == WeightUnit.kg) ? black : white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 5),
                          blurRadius: 2)
                    ]),
                child: Text(
                  "kg",
                  style: TextStyle(
                    color: (weightUnit == WeightUnit.kg) ? white : black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SpringButton(
              SpringButtonType.onlyScale,
              onTap: () {
                setState(() {
                  weightUnit = WeightUnit.lbs;
                });
              },
              uiChild: Container(
                width: 156,
                height: 52,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (weightUnit == WeightUnit.lbs) ? black : white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 5),
                          blurRadius: 2)
                    ]),
                child: Text(
                  "lbs",
                  style: TextStyle(
                    color: (weightUnit == WeightUnit.lbs) ? white : black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: kToolbarHeight),
        IntrinsicWidth(
          child: TextField(
            controller: wightTextEditingController,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 60,
                ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (value) {
              setState(() {
                initialWeightValue = double.tryParse(value) ?? 0;
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              suffix: Text(
                (weightUnit == WeightUnit.lbs) ? 'lbs' : 'kg',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ),
        RulerSlider(
          minValue: 0,
          maxValue: 300,
          initialValue: initialWeightValue,
          onValueChanged: (value) {
            wightTextEditingController.text = value.toStringAsFixed(1);
            initialWeightValue = value;
          },
        ),
        const Spacer(),
        SpringButton(
          SpringButtonType.onlyScale,
          onTap: () {
            setState(() {
              step = 2;
            });
          },
          uiChild: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Continue",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: white),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.arrow_forward,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Height section => step 2
  Column height(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: kToolbarHeight),
        Text(
          'What is your height?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: kToolbarHeight),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SpringButton(
              SpringButtonType.onlyScale,
              onTap: () {
                setState(() {
                  heightUnit = HeightUnit.cm;
                });
              },
              uiChild: Container(
                width: 156,
                height: 52,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (heightUnit == HeightUnit.cm) ? black : white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 5),
                          blurRadius: 2)
                    ]),
                child: Text(
                  "cm",
                  style: TextStyle(
                    color: (heightUnit == HeightUnit.cm) ? white : black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SpringButton(
              SpringButtonType.onlyScale,
              onTap: () {
                setState(() {
                  heightUnit = HeightUnit.ft;
                });
              },
              uiChild: Container(
                width: 156,
                height: 52,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: (heightUnit == HeightUnit.ft) ? black : white,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 5),
                          blurRadius: 2)
                    ]),
                child: Text(
                  "ft",
                  style: TextStyle(
                    color: (heightUnit == HeightUnit.ft) ? white : black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: kToolbarHeight),
        IntrinsicWidth(
          child: TextField(
            controller: heightTextEditingController,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 60,
                ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (value) {
              setState(() {
                initialHeightValue = double.tryParse(value) ?? 0;
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              suffix: Text(
                (heightUnit == HeightUnit.ft) ? 'ft' : 'cm',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ),
        RulerSlider(
          minValue: (heightUnit == HeightUnit.ft) ? -15 : 0,
          maxValue: (heightUnit == HeightUnit.ft) ? 30 : 400,
          initialValue: (heightUnit == HeightUnit.ft)
              ? initialHeightValue.clamp(1, 7)
              : initialHeightValue,
          onValueChanged: (value) {
            heightTextEditingController.text = value.toStringAsFixed(1);
            initialHeightValue = value;
          },
        ),
        const Spacer(),
        SpringButton(
          SpringButtonType.onlyScale,
          onTap: () {
            setState(() {
              step = 3;
            });
          },
          uiChild: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Continue",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: white),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.arrow_forward,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Gender section => step 3
  Widget genderWidget(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: kToolbarHeight),
        Text(
          'What is your Gender?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Please select your gender for better personalized health experience.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Expanded(
            child: GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16, // Horizontal spacing
            mainAxisSpacing: 16, // Vertical spacing
          ),
          children: [
            genderCard(gender: Gender.male),
            genderCard(gender: Gender.female),
            genderCard(gender: Gender.other),
            genderCard(gender: Gender.preferNotToSay),
          ],
        )),
        SpringButton(
          SpringButtonType.onlyScale,
          onTap: () {
            setState(() {
              step = 4;
            });
          },
          uiChild: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Continue",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: white),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.arrow_forward,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SpringButton genderCard({required Gender gender}) {
    return SpringButton(
      SpringButtonType.onlyScale,
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      uiChild: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selectedGender == gender ? primary : Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 1),
              color: selectedGender == gender ? primary : grey,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                CupertinoIcons.map_pin_ellipse,
                color: (selectedGender == gender) ? Colors.white : black,
              ),
            ),
            const Spacer(),
            Text(
              (gender == Gender.male)
                  ? "Male"
                  : (gender == Gender.female)
                      ? "Female"
                      : (gender == Gender.other)
                          ? "Other"
                          : (gender == Gender.preferNotToSay)
                              ? "Prefer Not to say"
                              : "",
              style: TextStyle(
                color: (selectedGender == gender) ? Colors.white : black,
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Health Goal => step 4
  Widget healthGoalWidget(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'What describes your current goal the most?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 20),
        Expanded(
            child: GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16, // Horizontal spacing
              mainAxisSpacing: 16, // Vertical spacing
              childAspectRatio: 2 / 1.5),
          children: [
            healthGoalCard(healthGoal: HealthGoal.lossWeight),
            healthGoalCard(healthGoal: HealthGoal.gainWeight),
            healthGoalCard(healthGoal: HealthGoal.maintainWeight),
            healthGoalCard(healthGoal: HealthGoal.gainMuscle),
            healthGoalCard(healthGoal: HealthGoal.lifeStyleImprove),
          ],
        )),
        SpringButton(
          SpringButtonType.onlyScale,
          onTap: () {
            setState(() {
              step = 5;
            });
          },
          uiChild: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Continue",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: white),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.arrow_forward,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget healthGoalCard({required HealthGoal healthGoal}) {
    return SpringButton(
      SpringButtonType.onlyScale,
      onTap: () {
        setState(() {
          selectedHealthGoal = healthGoal;
        });
      },
      uiChild: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selectedHealthGoal == healthGoal ? primary : Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 1),
              color: selectedHealthGoal == healthGoal ? primary : grey,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                CupertinoIcons.battery_25_percent,
                color:
                    (selectedHealthGoal == healthGoal) ? Colors.white : black,
              ),
            ),
            const Spacer(),
            Text(
              (healthGoal == HealthGoal.lossWeight)
                  ? "Loss weight"
                  : (healthGoal == HealthGoal.gainWeight)
                      ? "Gain weight"
                      : (healthGoal == HealthGoal.maintainWeight)
                          ? "Maintain current weight"
                          : (healthGoal == HealthGoal.gainMuscle)
                              ? "Loss weight and Gain muscle"
                              : "Lifestyle improvements",
              style: TextStyle(
                color:
                    (selectedHealthGoal == healthGoal) ? Colors.white : black,
              ),
            )
          ],
        ),
      ),
    );
  }

  /// age => step 5
  Widget ageWidget(BuildContext context){
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'What is your age?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: 19),
            itemExtent: 100,
            onSelectedItemChanged: (index) {
              setState(() {
                age = index+5;
              });
            },
            children: List.generate(
              50,
                  (index) => Center(
                child: Text(
                  '${index + 5}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
        ),
        Text(
          'I am $age years old.',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        SpringButton(
          SpringButtonType.onlyScale,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));
          },
          uiChild: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Continue",
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: white),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.arrow_forward,
                  color: white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
