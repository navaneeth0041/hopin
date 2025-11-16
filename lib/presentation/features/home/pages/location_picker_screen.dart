import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/services/location_service.dart';
import 'package:hopin/data/services/geocoding_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String title;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
    this.title = 'Select Location',
  });

  @override
  State<LocationPickerScreen> createState() =>
      _ImprovedLocationPickerScreenState();
}

class _ImprovedLocationPickerScreenState extends State<LocationPickerScreen> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  bool _isLoading = true;
  bool _isSearching = false;
  String _selectedAddress = '';
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
    _initializeLocation();
    if (_selectedLocation != null) {
      _loadAddress(_selectedLocation!);
    }
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        if (_selectedLocation == null) {
          _selectedLocation = _currentLocation;
          _loadAddress(_selectedLocation!);
        }
        _isLoading = false;
      });

      if (_selectedLocation != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _mapController.move(_selectedLocation!, 15.0);
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _loadAddress(LatLng location) async {
    final address = await GeocodingService.getAddressFromCoordinates(
      location.latitude,
      location.longitude,
    );
    setState(() {
      _selectedAddress = address;
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedLocation = position;
      _selectedAddress = 'Loading address...';
    });
    _loadAddress(position);
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    final results = await GeocodingService.searchPlaces(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectSearchResult(SearchResult result) {
    setState(() {
      _selectedLocation = result.location;
      _selectedAddress = result.displayName.split(',').take(2).join(',');
      _showSearchResults = false;
      _searchController.clear();
    });
    _mapController.move(result.location, 15.0);
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'location': _selectedLocation,
        'address': _selectedAddress,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      setState(() {
        _selectedLocation = _currentLocation;
      });
      _loadAddress(_currentLocation!);
      _mapController.move(_currentLocation!, 15.0);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: AppColors.primaryYellow,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryYellow),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _selectedLocation ?? const LatLng(9.9312, 76.2673),
                    initialZoom: 15.0,
                    onTap: _onMapTap,
                    minZoom: 3.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.hopin',
                    ),
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 50,
                            height: 50,
                            point: _selectedLocation!,
                            child: const Icon(
                              Icons.location_pin,
                              color: AppColors.accentRed,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search location',
                                  hintStyle: TextStyle(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  _searchPlaces(value);
                                },
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults = [];
                                    _showSearchResults = false;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),

                      if (_showSearchResults)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(maxHeight: 300),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _isSearching
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryYellow,
                                    ),
                                  ),
                                )
                              : _searchResults.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'No results found',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: _searchResults.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                        color: AppColors.divider,
                                        height: 1,
                                      ),
                                  itemBuilder: (context, index) {
                                    final result = _searchResults[index];
                                    return ListTile(
                                      leading: const Icon(
                                        Icons.location_on,
                                        color: AppColors.primaryYellow,
                                      ),
                                      title: Text(
                                        result.displayName
                                            .split(',')
                                            .take(2)
                                            .join(','),
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () => _selectSearchResult(result),
                                    );
                                  },
                                ),
                        ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.primaryYellow,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Selected Location',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_selectedLocation != null)
                          Text(
                            _selectedAddress,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            'Tap on the map to select a location',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _confirmLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryYellow,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Confirm Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 230,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _moveToCurrentLocation,
                    backgroundColor: AppColors.primaryYellow,
                    child: const Icon(Icons.my_location, color: Colors.black),
                  ),
                ),
              ],
            ),
    );
  }
}
