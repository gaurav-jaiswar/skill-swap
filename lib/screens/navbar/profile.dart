import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/provider/home_provider.dart';
import 'package:skill_swap/screens/auth/add_skills.dart';
import 'package:skill_swap/screens/auth/login_screen.dart';
import 'package:skill_swap/screens/other/chat_screen.dart';
import 'package:skill_swap/screens/other/show_skills.dart';
import 'package:skill_swap/screens/other/swap_request.dart';
import 'package:skill_swap/utils/cloudinary_helper.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/extensions.dart';
import 'package:skill_swap/utils/transition.dart';
import 'package:skill_swap/widgets/loading_popup.dart';
import 'package:skill_swap/widgets/show_rating.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.user});
  final User user;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late bool isOwner;
  late User user;
  @override
  void initState() {
    super.initState();
    user = widget.user;
    isOwner = user.email == UserController.user.email;
    // isOwner = false;
  }

  void changeCoverPic() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            initAspectRatio: CropAspectRatioPreset.square,
            toolbarTitle: 'Cropper',
            toolbarColor: Color.fromRGBO(58, 58, 58, 1),
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [CropAspectRatioPresetCustom()],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [CropAspectRatioPresetCustom()],
          ),
        ],
      );
      if (croppedImage != null) {
        final url = await CloudinaryHelper.uploadImage(
          context,
          croppedImage.path,
        );
        if (url != null) {
          showLoadingPopup(context, "Updating...");
          if (UserController.user.coverPic != null) {
            final imageId =
                UserController.user.coverPic!.split("/").last.split(".").first;
            await CloudinaryHelper.deleteImage(imageId);
            Navigator.of(context).pop();
          }

          await UserController.update({"coverPic": url});
          user = UserController.user;
          if (mounted) {
            setState(() {});
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final isOwner = false;
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).width * 3 / 8,
                decoration: BoxDecoration(
                  image:
                      user.coverPic == null
                          ? DecorationImage(
                            scale: 2,
                            alignment: Alignment(0.9, 0),
                            image: AssetImage('assets/images/name.png'),
                          )
                          : DecorationImage(
                            image: NetworkImage(user.coverPic!),
                            fit: BoxFit.cover,
                          ),
                  color: const Color.fromARGB(255, 68, 78, 87),
                ),
                alignment: Alignment.bottomRight,
                child:
                    isOwner
                        ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          child: InkWell(
                            onTap: changeCoverPic,
                            child: Icon(Icons.edit_outlined),
                          ),
                        )
                        : null,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: (MediaQuery.sizeOf(context).width * 3 / 8) / 2,
                  left: MediaQuery.sizeOf(context).width * .04,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: CircleAvatar(
                            radius:
                                (MediaQuery.sizeOf(context).width * 3 / 16) - 4,
                            foregroundImage:
                                user.profilePic == null
                                    ? user.gender == "Male"
                                        ? AssetImage(
                                          'assets/images/avatarm.png',
                                        )
                                        : AssetImage(
                                          'assets/images/avatarf.png',
                                        )
                                    : NetworkImage(user.profilePic!),
                          ),
                        ),
                        if (isOwner)
                          IconButton.filled(
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              maxWidth: 35,
                              maxHeight: 35,
                            ),
                            onPressed: () async {
                              final result = await showProfilePicOptions();
                              if (result == true && mounted) {
                                setState(() {});
                              }
                            },
                            icon: Icon(Icons.edit_outlined, size: 20),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 25),
                      child: ShowRatingWidget(
                        ratings: (user.ratings ?? {}).values.toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          //Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 5,
                    ),
                    child: Text(
                      user.name ?? "",
                      style: TextStyle(
                        fontSize: large,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isOwner)
                    Padding(
                      padding: const EdgeInsets.only(right: 10, left: 6),
                      child: InkWell(
                        onTap: () async {
                          final change = await showTextEditorPopUp(
                            context,
                            hintText: "Name",
                          );
                          if (change is String) {
                            showLoadingPopup(context, "Updating");
                            await UserController.update({'name': change});
                            Navigator.of(context).pop();
                            user = UserController.user;
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        },
                        child: Icon(Icons.edit_outlined),
                      ),
                    ),
                ],
              ),

              //Bio
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        (user.bio ?? '').isNotEmpty
                            ? user.bio!
                            : isOwner
                            ? "Bio is not added to your profile.\nAdd a bio to help others get to know you better!"
                            : "No Bio added!",
                      ),
                    ),
                  ),
                  if (isOwner)
                    Padding(
                      padding: const EdgeInsets.only(right: 10, left: 6),
                      child: InkWell(
                        onTap: () async {
                          final change = await showTextEditorPopUp(
                            context,
                            hintText: "Bio",
                          );
                          if (change is String) {
                            showLoadingPopup(context, "Updating");
                            await UserController.update({'bio': change});
                            Navigator.of(context).pop();
                            user = UserController.user;
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        },
                        child: Icon(
                          (user.bio ?? "").isEmpty
                              ? Icons.add
                              : Icons.edit_outlined,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 30),
                ],
              ),
              isOwner
                  ? const SizedBox(height: 10)
                  : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              transitionToNextScreen(
                                ChatScreen(
                                  userId: user.email!,
                                  fromHome: false,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff81d3df),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.message_outlined, color: Colors.black),
                              Text(
                                "  Message",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              transitionToNextScreen(
                                SwapRequest(
                                  skills: user.skills!,
                                  userId: user.email!,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff81d3df),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.black),
                              Text(
                                " Swap Request",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                color: const Color.fromARGB(255, 68, 78, 87),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: isOwner ? 0 : 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Skills",
                            style: TextStyle(
                              fontSize: mediumLarge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isOwner)
                            IconButton(
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  transitionToNextScreen(
                                    AddSkillsPage(
                                      isSkillWanted: false,
                                      update: true,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  user = UserController.user;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                }
                              },
                              icon: Icon(Icons.add),
                            ),
                        ],
                      ),
                    ),
                    if (user.skills!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "No Skills Found${isOwner ? ', Please Add Some...' : ''}",
                        ),
                      )
                    else
                      for (
                        int i = 0;
                        i < (user.skills!.length < 3 ? user.skills!.length : 2);
                        i++
                      )
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (i != 0) Divider(color: Colors.grey),
                              Text(
                                user.skills![i].toString().capitalize(),
                                style: TextStyle(
                                  fontSize: medium,
                                  // fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    const SizedBox(height: 8),
                    if (user.skills!.length > 2)
                      Divider(color: Colors.grey, height: 4),
                    if (user.skills!.length > 2)
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            transitionToNextScreen(
                              ShowSkills(
                                skills: user.skills!,
                                appBarTitle: "Skills you have",
                                selection: false,
                                isOwner: isOwner,
                              ),
                            ),
                          );
                          if (result is Set) {
                            showLoadingPopup(context, "Updating...");
                            await UserController.update({
                              'skills': FieldValue.arrayRemove(result.toList()),
                            });
                            user = UserController.user;
                            Navigator.of(context).pop();
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Show All ${user.skills!.length} skills   ",
                              style: TextStyle(fontSize: mediumSmall),
                            ),
                            Icon(Icons.arrow_forward_outlined, size: medium),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                color: const Color.fromARGB(255, 68, 78, 87),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: isOwner ? 0 : 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Skills want to Learn",
                            style: TextStyle(
                              fontSize: mediumLarge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isOwner)
                            IconButton(
                              onPressed: () async {
                                final needsRealod = await Navigator.of(
                                  context,
                                ).push(
                                  transitionToNextScreen(
                                    AddSkillsPage(
                                      isSkillWanted: true,
                                      update: true,
                                    ),
                                  ),
                                );
                                if (needsRealod == true) {
                                  user = UserController.user;
                                  setState(() {});
                                }
                              },
                              icon: Icon(Icons.add),
                            ),
                        ],
                      ),
                    ),
                    if (user.skillsNeeded!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "No Skills Found${isOwner ? ', Please Add Some...' : ''}",
                        ),
                      )
                    else
                      for (
                        int i = 0;
                        i <
                            (user.skillsNeeded!.length < 3
                                ? user.skillsNeeded!.length
                                : 2);
                        i++
                      )
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (i != 0) Divider(color: Colors.grey),
                              Text(
                                user.skillsNeeded![i].toString().capitalize(),
                                style: TextStyle(
                                  fontSize: medium,
                                  // fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    const SizedBox(height: 8),
                    if (user.skillsNeeded!.length > 2)
                      Divider(color: Colors.grey, height: 4),
                    if (user.skillsNeeded!.length > 2)
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            transitionToNextScreen(
                              ShowSkills(
                                skills: user.skillsNeeded!,
                                appBarTitle: "Skills want to learn",
                                selection: false,
                                isOwner: isOwner,
                              ),
                            ),
                          );
                          if (result is Set) {
                            showLoadingPopup(context, "Updating...");
                            await UserController.update({
                              'skillsNeeded': FieldValue.arrayRemove(
                                result.toList(),
                              ),
                            });
                            user = UserController.user;
                            Navigator.of(context).pop();
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Show All ${user.skillsNeeded!.length} skills   ",
                              style: TextStyle(fontSize: mediumSmall),
                            ),
                            Icon(Icons.arrow_forward_outlined, size: medium),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          if (isOwner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: ElevatedButton(
                onPressed: () async {
                  showLoadingPopup(context, "Logging Out");
                  context.read<HomeProvider>().stream!.cancel();
                  await fb.FirebaseAuth.instance.signOut();
                  context.read<HomeProvider>().clear();

                  Navigator.of(context).pushAndRemoveUntil(
                    transitionToNextScreen(const LoginScreen()),
                    (_) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff81d3df),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_outlined,
                      color: Colors.black,
                      applyTextScaling: true,
                    ),
                    Text(
                      "  Logout",
                      style: TextStyle(color: Colors.black, fontSize: medium),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future showProfilePicOptions() async {
    if (UserController.user.profilePic == null) {
      final url = await CloudinaryHelper.pickAndGetLink(
        context,
        cropImage: true,
      );
      if (url != null) {
        showLoadingPopup(context, "Updating");
        if (UserController.user.profilePic != null) {
          final imageId =
              UserController.user.profilePic!.split("/").last.split(".").first;
          await CloudinaryHelper.deleteImage(imageId);
        }
        await UserController.update({'profilePic': url});
        Navigator.of(context).pop();
        user = UserController.user;
        return true;
      }
    }

    return await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey),
            ),
            insetPadding: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Profile Photo Action"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          showLoadingPopup(context, "Updating");
                          if (UserController.user.profilePic != null) {
                            final imageId =
                                UserController.user.profilePic!
                                    .split("/")
                                    .last
                                    .split(".")
                                    .first;
                            await CloudinaryHelper.deleteImage(imageId);
                          }
                          await UserController.update({'profilePic': null});
                          Navigator.of(context).pop();
                          user = UserController.user;
                          Navigator.of(context).pop(true);
                        },
                        child: Text('Remove'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final url = await CloudinaryHelper.pickAndGetLink(
                            context,
                            cropImage: true,
                          );
                          if (url != null) {
                            showLoadingPopup(context, "Updating");
                            if (UserController.user.profilePic != null) {
                              final imageId =
                                  UserController.user.profilePic!
                                      .split("/")
                                      .last
                                      .split(".")
                                      .first;
                              await CloudinaryHelper.deleteImage(imageId);
                            }
                            await UserController.update({'profilePic': url});
                            Navigator.of(context).pop();
                            user = UserController.user;
                            Navigator.of(context).pop(true);
                          }
                        },
                        child: Text('Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future showTextEditorPopUp(
    BuildContext context, {
    required String hintText,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          insetPadding: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  minLines: 1,
                  maxLines: 4,
                  autofocus: true,
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: hintText,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(controller.text);
                  },
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
