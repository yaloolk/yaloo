// lib/features/host/screens/host_stay_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yaloo/features/host/providers/host_provider.dart';

class HostStayEditScreen extends StatefulWidget {
  final String stayId;

  const HostStayEditScreen({super.key, required this.stayId});

  @override
  State<HostStayEditScreen> createState() => _HostStayEditScreenState();
}

class _HostStayEditScreenState extends State<HostStayEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _houseNoCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _townCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _roomCountCtrl = TextEditingController();
  final _maxGuestsCtrl = TextEditingController();
  final _pricePerNightCtrl = TextEditingController();
  final _bathroomCountCtrl = TextEditingController();

  String? _selectedType;
  String? _selectedCityId;
  LatLng? _selectedLocation;
  List<String> _selectedFacilityIds = [];
  bool _isSaving = false;
  bool _isDeletingPhoto = false;
  String? _deletingPhotoId;
  bool _isAddingPhotos = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _houseNoCtrl.dispose();
    _streetCtrl.dispose();
    _townCtrl.dispose();
    _postalCodeCtrl.dispose();
    _roomCountCtrl.dispose();
    _maxGuestsCtrl.dispose();
    _pricePerNightCtrl.dispose();
    _bathroomCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<HostProvider>();
    await Future.wait([
      provider.loadStayDetail(widget.stayId),
      provider.loadFacilities(),
      provider.loadCities(),
    ]);

    if (mounted) _populateFields();
  }

  void _populateFields() {
    final detail = context.read<HostProvider>().selectedStayDetail;
    if (detail == null) return;

    _nameCtrl.text = detail.name;
    _descriptionCtrl.text = detail.description;
    _houseNoCtrl.text = detail.houseNo;
    _streetCtrl.text = detail.street;
    _townCtrl.text = detail.town;
    _postalCodeCtrl.text = detail.postalCode?.toString() ?? '';
    _roomCountCtrl.text = detail.roomCount.toString();
    _maxGuestsCtrl.text = detail.maxGuests.toString();
    _pricePerNightCtrl.text = detail.pricePerNight.toString();
    _bathroomCountCtrl.text = detail.bathroomCount.toString();

    setState(() {
      _selectedType = detail.type;
      _selectedCityId = detail.cityId;
      _selectedFacilityIds = List.from(detail.facilityIds);
      if (detail.latitude != null && detail.longitude != null) {
        _selectedLocation = LatLng(detail.latitude!, detail.longitude!);
      }
    });
  }

  Future<void> _saveStay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<HostProvider>();

    final data = {
      'name': _nameCtrl.text,
      'type': _selectedType,
      'description': _descriptionCtrl.text,
      'house_no': _houseNoCtrl.text,
      'street': _streetCtrl.text,
      'town': _townCtrl.text,
      'city_id': _selectedCityId,
      'postal_code': int.tryParse(_postalCodeCtrl.text),
      'latitude': _selectedLocation?.latitude,
      'longitude': _selectedLocation?.longitude,
      'room_count': int.tryParse(_roomCountCtrl.text) ?? 0,
      'max_guests': int.tryParse(_maxGuestsCtrl.text) ?? 0,
      'price_per_night': double.tryParse(_pricePerNightCtrl.text) ?? 0,
      'bathroom_count': int.tryParse(_bathroomCountCtrl.text) ?? 0,
    };

    final success = await provider.updateStay(widget.stayId, data);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Stay updated! ✓' : 'Error: ${provider.error}'),
          backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _deletePhoto(String photoId) async {
    HapticFeedback.mediumImpact();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeletingPhoto = true;
      _deletingPhotoId = photoId;
    });

    final provider = context.read<HostProvider>();
    final success = await provider.deleteStayPhoto(widget.stayId, photoId);

    setState(() {
      _isDeletingPhoto = false;
      _deletingPhotoId = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Photo deleted' : 'Failed to delete photo'),
          backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _addPhotos() async {
    HapticFeedback.mediumImpact();
    final images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    setState(() => _isAddingPhotos = true);

    final provider = context.read<HostProvider>();
    final success = await provider.addStayPhotos(widget.stayId, images);

    setState(() => _isAddingPhotos = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '${images.length} photo(s) added' : 'Failed to add photos'),
          backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: Consumer<HostProvider>(
                builder: (context, provider, _) {
                  if (provider.stayDetailLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                    );
                  }

                  if (provider.selectedStayDetail == null) {
                    return const Center(child: Text('Stay not found'));
                  }

                  return Form(
                    key: _formKey,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBasicTab(),
                        _buildLocationTab(),
                        _buildPhotosTab(provider),
                        _buildAmenitiesTab(provider),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Edit Property',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2563EB),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFF2563EB),
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Basic'),
          Tab(text: 'Location'),
          Tab(text: 'Photos'),
          Tab(text: 'Amenities'),
        ],
      ),
    );
  }

  Widget _buildBasicTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTextField(
          controller: _nameCtrl,
          label: 'Property Name *',
          icon: Icons.home_outlined,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          value: _selectedType,
          label: 'Property Type *',
          icon: Icons.category_outlined,
          items: const [
            DropdownMenuItem(value: 'homestay', child: Text('Homestay')),
            DropdownMenuItem(value: 'farm_stay', child: Text('Farm Stay')),
            DropdownMenuItem(value: 'villa', child: Text('Villa')),
            DropdownMenuItem(value: 'guesthouse', child: Text('Guesthouse')),
            DropdownMenuItem(value: 'eco_lodge', child: Text('Eco Lodge')),
            DropdownMenuItem(value: 'hostel', child: Text('Hostel')),
          ],
          onChanged: (v) => setState(() => _selectedType = v),
          validator: (v) => v == null ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionCtrl,
          label: 'Description',
          icon: Icons.description_outlined,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _roomCountCtrl,
                label: 'Rooms *',
                icon: Icons.meeting_room_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _maxGuestsCtrl,
                label: 'Guests *',
                icon: Icons.people_outline,
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _bathroomCountCtrl,
                label: 'Bathrooms *',
                icon: Icons.bathroom_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _pricePerNightCtrl,
                label: 'Price/Night *',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTextField(
          controller: _houseNoCtrl,
          label: 'House Number',
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _streetCtrl,
          label: 'Street',
          icon: Icons.signpost_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _townCtrl,
          label: 'Town',
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 16),
        Consumer<HostProvider>(
          builder: (context, provider, _) {
            return _buildDropdown(
              value: _selectedCityId,
              label: 'City *',
              icon: Icons.location_on_outlined,
              items: provider.cities
                  .map((city) => DropdownMenuItem(
                value: city.id,
                child: Text(city.name),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCityId = v),
              validator: (v) => v == null ? 'Required' : null,
            );
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _postalCodeCtrl,
          label: 'Postal Code',
          icon: Icons.local_post_office_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _selectedLocation != null
                ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation!,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('stay'),
                  position: _selectedLocation!,
                ),
              },
              onTap: (latLng) {
                setState(() => _selectedLocation = latLng);
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap map to set location',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosTab(HostProvider provider) {
    final stay = provider.selectedStayDetail;
    final photos = stay?.photos ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Add Photos Button
        GestureDetector(
          onTap: _isAddingPhotos ? null : _addPhotos,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isAddingPhotos)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(Icons.add_photo_alternate, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _isAddingPhotos ? 'Uploading...' : 'Add Photos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (photos.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No photos yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add photos to showcase your property',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: photos.length,
            itemBuilder: (_, index) {
              final photo = photos[index];
              final isDeleting = _deletingPhotoId == photo.id;

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Photo with error handling
                    Image.network(
                      photo.url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFF2563EB),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        );
                      },
                    ),

                    // Delete button
                    if (isDeleting)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _deletePhoto(photo.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),

                    // Photo number indicator
                    if (index == 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Cover',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAmenitiesTab(HostProvider provider) {
    final facilities = provider.facilities;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (facilities.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: facilities.map((facility) {
              final isSelected = _selectedFacilityIds.contains(facility.id);
              return FilterChip(
                label: Text(facility.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFacilityIds.add(facility.id);
                    } else {
                      _selectedFacilityIds.remove(facility.id);
                    }
                  });
                },
                selectedColor: const Color(0xFF2563EB).withOpacity(0.15),
                checkmarkColor: const Color(0xFF2563EB),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            HapticFeedback.mediumImpact();
            final provider = context.read<HostProvider>();
            final success = await provider.updateStayFacilities(
              widget.stayId,
              _selectedFacilityIds,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Amenities updated! ✓' : 'Failed to update amenities'),
                  backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              );
            }
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Amenities'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  // Improved Save Button - Floating style with gradient
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: _isSaving ? null : _saveStay,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: _isSaving
                  ? LinearGradient(
                colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade500,
                ],
              )
                  : const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: _isSaving ? null : [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSaving)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(Icons.save_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  _isSaving ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2563EB)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF1F2937),
      ),
    );
  }
}