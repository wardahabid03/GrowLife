import 'package:flutter/material.dart';
import 'package:grow_life/colors.dart';
import 'package:grow_life/plant_model.dart';
import 'package:grow_life/plant_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlantSearchPage extends StatefulWidget {
  @override
  _PlantSearchPageState createState() => _PlantSearchPageState();
}

class _PlantSearchPageState extends State<PlantSearchPage> {
  final PlantService _plantService = PlantService();
  List<Plant> _plants = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  int? _selectedPlantId;

  Future<void> _searchPlants() async {
    setState(() {
      _isLoading = true;
      _plants = [];
    });
    try {
      final plants = await _plantService.fetchPlants(_searchController.text);
      setState(() {
        _plants = plants;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPlantDetails(int id) async {
    try {
      final plant = await _plantService.fetchPlantDetails(id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantDetailPage(plant: plant),
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Finder', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            SizedBox(height: 16),
            _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search for plants',
          labelStyle: TextStyle(color: AppColors.textColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: AppColors.primaryColor),
            onPressed: _searchPlants,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_plants.isEmpty) {
      return const Center(
  child: Padding(
    padding: EdgeInsets.all(18.0),
    child: Text(
      'Looking for detailed information on plants? Search here!',
      style: TextStyle(
        color: AppColors.textColor,
        fontSize: 18,
  
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    ),
  ),
);

    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: _plants.length,
          itemBuilder: (context, index) {
            final plant = _plants[index];
            return _buildPlantCard(plant);
          },
        ),
      );
    }
  }

  Widget _buildPlantCard(Plant plant) {
    print('Plant Image URL: ${plant.imageUrl}'); // Debug statement

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(8.0),
        leading: plant.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: plant.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(), // Loading indicator
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ), // Error indicator
              )
            : Icon(
                Icons.image,
                size: 50,
                color: Colors.grey, // Placeholder color
              ),
        title: Text(
          plant.commonName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(plant.scientificName.join(', ')),
        onTap: () {
          _fetchPlantDetails(
              plant.id); // Pass the plant ID to fetch detailed info
        },
      ),
    );
  }
}

class PlantDetailPage extends StatefulWidget {
  final Plant plant;

  PlantDetailPage({required this.plant});

  @override
  _PlantDetailPageState createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;

    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Details'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          plant.imageUrl!,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Placeholder(
                            fallbackHeight: 200,
                            color: AppColors.lightGreenBackground,
                          ),
                        ),
                      ),
                    )
                  : const Placeholder(
                      fallbackHeight: 200,
                      color: AppColors.lightGreenBackground),
              const SizedBox(height: 16),
              _buildDetailItem(Icons.tag, 'Common Name', plant.commonName),
              _buildDetailItem(Icons.science, 'Scientific Name',
                  plant.scientificName.join(', ')),
              _buildDetailItem(Icons.opacity, 'Watering', plant.watering),
              _buildDetailItem(
                  Icons.wb_sunny, 'Sunlight', plant.sunlight.join(', ')),
              _buildDetailItem(Icons.category, 'Type', plant.type ?? 'N/A'),
              _buildDetailItem(Icons.calendar_today, 'Cycle', plant.cycle),
              if (_isExpanded) ...[
                _buildDetailItem(
                    Icons.schedule, 'Watering Period', plant.wateringPeriod),
                _buildDetailItem(Icons.nature_people, 'Propagation',
                    plant.propagation.join(', ')),
                _buildDetailItem(
                    Icons.edit, 'Pruning Month', plant.pruningMonth.join(', ')),
                _buildDetailItem(Icons.circle, 'Seeds', plant.seeds.toString()),
                _buildDetailItem(
                    Icons.star, 'Flowers', plant.flowers ? 'Yes' : 'No'),
                _buildDetailItem(Icons.calendar_today, 'Flowering Season',
                    plant.floweringSeason ?? 'N/A'),
                _buildDetailItem(Icons.restaurant, 'Edible Fruit',
                    plant.edibleFruit ? 'Yes' : 'No'),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(_isExpanded ? 'Read Less' : 'Read More',style: TextStyle(color: AppColors.primaryColor),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String detail) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
