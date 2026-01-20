import 'package:flutter/material.dart';
import 'package:food_bridge/controllers/create_post_controller.dart';
import 'package:food_bridge/utils/theme/colors.dart';
import 'package:food_bridge/views/widgets/custom_bw_button.dart';
import 'package:food_bridge/views/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final CreatePostController controller = Get.put(CreatePostController());

  final Color textColor = const Color(0xFF333333);
  final Color shadowLight = Colors.white.withValues(alpha: 0.9);
  final Color shadowDark = Colors.black.withValues(alpha: 0.12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Create Post", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeToggle(),
              const SizedBox(height: 20),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildForm(),
              const SizedBox(height: 30),
              CustomBWButton(
                isLoading: controller.isLoading.value,
                title: "Post Now",
                bgColor: AppColors.primary,
                shadowLight: shadowLight,
                shadowDark: shadowDark,
                textColor: Colors.white,
                onTap: controller.createPost,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildtoggleButton("Food Share", 0)),
          Expanded(child: _buildtoggleButton("Fundraising", 1)),
        ],
      ),
    );
  }

  Widget _buildtoggleButton(String title, int index) {
    bool isSelected = controller.selectedPostType.value == index;
    return GestureDetector(
      onTap: () => controller.selectedPostType.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSourceButton(
                "Gallery",
                !controller.isUsingUrl.value,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildSourceButton("URL", controller.isUsingUrl.value),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (controller.isUsingUrl.value)
          CustomTextField(
            controller: controller.imageUrlController,
            icon: Icons.link,
            hint: "Paste image URL here",
            bgColor: Colors.white,
            shadowLight: shadowLight,
            shadowDark: shadowDark,
            textColor: textColor,
            onChanged: (val) {
              setState(() {}); // For preview update
            },
          )
        else
          GestureDetector(
            onTap: controller.pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: controller.selectedImage.value != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        controller.selectedImage.value!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "Tap to add photo",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
        if (controller.isUsingUrl.value &&
            controller.imageUrlController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                controller.imageUrlController.text,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Center(child: Text("Invalid Image URL")),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSourceButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        controller.isUsingUrl.value = title == "URL";
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    bool isFundraising = controller.selectedPostType.value == 1;

    return Column(
      children: [
        CustomTextField(
          controller: controller.titleController,
          icon: Icons.title,
          hint: "Title",
          bgColor: Colors.white,
          shadowLight: shadowLight,
          shadowDark: shadowDark,
          textColor: textColor,
        ),
        const SizedBox(height: 15),

        // Multi-line description manually styled container since CustomTextField might not support maxLines easily (checking implementation it relies on default)
        // Adjusting CustomTextField usage or building similar container.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: shadowLight,
                offset: const Offset(-4, -4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: shadowDark,
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller.descriptionController,
            maxLines: 4,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(
                Icons.description,
                color: textColor.withValues(alpha: 0.7),
              ),
              hintText: "Description",
              hintStyle: TextStyle(color: textColor.withValues(alpha: 0.5)),
            ),
          ),
        ),

        const SizedBox(height: 15),
        if (!isFundraising) ...[
          Row(
            children: [
              const Text(
                "Type: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Obx(
                () => DropdownButton<String>(
                  value: controller.foodType.value,
                  items: ["Free", "Sale"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.foodType.value = val;
                  },
                ),
              ),
            ],
          ),
          if (controller.foodType.value == 'Sale')
            CustomTextField(
              controller: controller.priceController,
              icon: Icons.attach_money,
              hint: "Price",
              bgColor: Colors.white,
              shadowLight: shadowLight,
              shadowDark: shadowDark,
              textColor: textColor,
            ),
          if (controller.foodType.value == 'Sale') const SizedBox(height: 15),
          CustomTextField(
            controller: controller.quantityController,
            icon: Icons.shopping_bag_outlined,
            hint: "Quantity (e.g. 5 packets)",
            bgColor: Colors.white,
            shadowLight: shadowLight,
            shadowDark: shadowDark,
            textColor: textColor,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: controller.locationController,
            icon: Icons.location_on_outlined,
            hint: "Pickup Location",
            bgColor: Colors.white,
            shadowLight: shadowLight,
            shadowDark: shadowDark,
            textColor: textColor,
          ),
        ] else ...[
          CustomTextField(
            controller: controller.targetController,
            icon: Icons.monetization_on_outlined,
            hint: "Target Amount (BDT)",
            bgColor: Colors.white,
            shadowLight: shadowLight,
            shadowDark: shadowDark,
            textColor: textColor,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: controller.phoneController,
            icon: Icons.phone,
            hint: "Contact Number",
            bgColor: Colors.white,
            shadowLight: shadowLight,
            shadowDark: shadowDark,
            textColor: textColor,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: controller.locationController,
            icon: Icons.tag,
            hint: "Tag / Location",
            bgColor: Colors.white,
            shadowLight: shadowLight,
            shadowDark: shadowDark,
            textColor: textColor,
          ),
        ],
      ],
    );
  }
}
