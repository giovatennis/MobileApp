import 'package:favorites/models/city_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class CityCard extends StatelessWidget {
  final CityModel city;
  
  const CityCard({
    super.key,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              "assets/images/${city.cityImage}.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 5,
            left: 12,
            right: 12,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                city.cityName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              IconButton(
                onPressed: () { 
                  context.read<FavoritesProvider>().toggleCityFavorite(city.id);
                }, 
                icon: Icon(
                  city.isFavorite ? 
                  Icons.favorite : 
                  Icons.favorite_border,
                color: 
                city.isFavorite ? 
                Colors.red : 
                Colors.black54))
            ],
          ))

        ],
      ),
    );
  }
}
