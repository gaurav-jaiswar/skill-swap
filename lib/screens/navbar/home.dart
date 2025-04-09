import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_swap/controllers/models.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/provider/home_provider.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/extensions.dart';
import 'package:skill_swap/widgets/home/complete.dart';
import 'package:skill_swap/widgets/home/suggestion_card.dart';
import 'package:skill_swap/widgets/home/swap_request_tile.dart';
import 'package:skill_swap/widgets/home/swap_tile.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 144, 187, 209),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 25,
                    foregroundImage:
                        UserController.user.profilePic == null
                            ? UserController.user.gender == "Male"
                                ? AssetImage('assets/images/avatarm.png')
                                : AssetImage('assets/images/avatarf.png')
                            : NetworkImage(UserController.user.profilePic!),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Hi, ${UserController.user.name!.split(" ")[0].capitalize()}! 👋",
                  style: TextStyle(
                    fontSize: mediumLarge,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Consumer<HomeProvider>(
              builder:
                  (context, value, child) =>
                      value.pendingDetails > 0
                          ? CompleteProfile(
                            pendingDetails: value.pendingDetails,
                          )
                          : SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            //Suggestions
            Consumer<HomeProvider>(
              builder:
                  (context, value, child) =>
                      value.suggestions.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Swap Suggestions",
                                style: TextStyle(
                                  fontSize: medium,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 10),

                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 195,
                                  maxWidth: MediaQuery.sizeOf(context).width,
                                ),
                                child: ListView.builder(
                                  itemCount: value.suggestions.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder:
                                      (context, index) => Column(
                                        children: [
                                          SuggestionCard(
                                            user: User.fromJson(
                                              value.suggestions[index].value,
                                            ),
                                            skills:
                                                value.suggestions[index].key,
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                            ],
                          ),
            ),

            //swap requests made
            Consumer<HomeProvider>(
              builder:
                  (context, value, child) =>
                      value.swapRequestsMade.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Swaps Requested",
                                style: TextStyle(
                                  fontSize: medium,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 10),

                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 240,
                                  maxWidth: MediaQuery.sizeOf(context).width,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: value.swapRequestsMade.length,
                                  itemBuilder:
                                      (context, index) => Column(
                                        children: [
                                          SwapRequestTile(
                                            swapData: SwapRequestModel.fromJson(
                                              value.swapRequestsMade[index],
                                            ),
                                            isRequestReceived: false,
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                            ],
                          ),
            ),

            //Swaps requests received
            Consumer<HomeProvider>(
              builder:
                  (context, value, child) =>
                      value.swapRequests.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Swaps Requests",
                                style: TextStyle(
                                  fontSize: medium,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 10),

                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 240,
                                  maxWidth: MediaQuery.sizeOf(context).width,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: value.swapRequests.length,
                                  itemBuilder:
                                      (context, index) => Column(
                                        children: [
                                          SwapRequestTile(
                                            swapData: SwapRequestModel.fromJson(
                                              value.swapRequests[index],
                                            ),
                                            isRequestReceived: true,
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
            ),

            //active swaps
            Consumer<HomeProvider>(
              builder:
                  (context, value, child) =>
                      value.activeSwaps.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Active Swaps",
                                style: TextStyle(
                                  fontSize: medium,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 10),

                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 240,
                                  maxWidth: MediaQuery.sizeOf(context).width,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: value.activeSwaps.length,
                                  itemBuilder:
                                      (context, index) => Column(
                                        children: [
                                          SwapTile(
                                            swapData: SwapModel.fromJson(
                                              value.activeSwaps[index],
                                            ),
                                            isCompleted: false,
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                            ],
                          ),
            ),

            //Completed swaps
            Consumer<HomeProvider>(
              builder:
                  (context, value, child) =>
                      value.completedSwaps.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Completed Swaps",
                                style: TextStyle(
                                  fontSize: medium,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 10),

                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 240,
                                  maxWidth: MediaQuery.sizeOf(context).width,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: value.completedSwaps.length,
                                  itemBuilder:
                                      (context, index) => Column(
                                        children: [
                                          SwapTile(
                                            swapData: SwapModel.fromJson(
                                              value.completedSwaps[index],
                                            ),
                                            isCompleted: true,
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
            ),
          ],
        ),
      ),
    );
  }
}
