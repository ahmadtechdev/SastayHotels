// models/feature_item.dart
import 'package:flutter/material.dart';

import '../widgets/colors.dart';

class FeatureItem {
  final String title;
  final String imagePath;
  final String description;

  FeatureItem({
    required this.title,
    required this.imagePath,
    required this.description,
  });
}

class FeatureCarousel extends StatefulWidget {
  const FeatureCarousel({Key? key}) : super(key: key);

  @override
  _FeatureCarouselState createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<FeatureItem> features = [
    FeatureItem(
      title: '24/7 Customer Support',
      imagePath: 'assets/img/support.png',
      description: 'Always here to help',
    ),
    FeatureItem(
      title: 'Refunds within 48 hours',
      imagePath: 'assets/img/refund.png',
      description: 'Quick and hassle-free',
    ),
    FeatureItem(
      title: 'Secure Transactions',
      imagePath: 'assets/img/secure.png',
      description: 'Your safety is our priority',
    ),
    // Add fourth feature item here
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final nextPage = (_currentPage + 1) % features.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 290,
      color: TColors.primary.withOpacity(0.1),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: features.length,
              itemBuilder: (context, index) {
                return FeatureCard(feature: features[index]);
              },
            ),
          ),
          const SizedBox(height: 8),
          DotsIndicator(
            currentPage: _currentPage,
            itemCount: features.length,
          ),
        ],
      ),
    );
  }
}

// widgets/feature_card.dart
class FeatureCard extends StatelessWidget {
  final FeatureItem feature;

  const FeatureCard({required this.feature, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          children: [
            Image.asset(
              feature.imagePath,
              width: 250,
              height: 200,
            ),
            Row(
              children: [

                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        feature.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TColors.text,
                        ),
                      ),
                      Text(
                        feature.description,
                        style: const TextStyle(
                          color: TColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedPartners extends StatefulWidget {
  const FeaturedPartners({Key? key}) : super(key: key);

  @override
  State<FeaturedPartners> createState() => _FeaturedPartnersState();
}

class _FeaturedPartnersState extends State<FeaturedPartners> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> partnerLogos = [
    'assets/img/logos/Air-Sial.png',
    'assets/img/logos/pia.png',
    'assets/img/logos/serena.png',
    'assets/img/logos/flyjinnah.png',
    'assets/img/logos/Air-Sial.png',
    'assets/img/logos/fly-dubai.png',
    'assets/img/logos/air-arabia.png',
    'assets/img/logos/emirates.png',
    'assets/img/logos/Air-Sial.png',
    'assets/img/logos/pia.png',
    'assets/img/logos/serena.png',
    'assets/img/logos/flyjinnah.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<List<String>> _getPagedLogos() {
    final int logosPerPage = 6; // 2 rows × 3 columns
    final List<List<String>> pages = [];

    for (var i = 0; i < partnerLogos.length; i += logosPerPage) {
      final end = (i + logosPerPage < partnerLogos.length)
          ? i + logosPerPage
          : partnerLogos.length;
      pages.add(partnerLogos.sublist(i, end));
    }

    return pages;
  }

  Widget _buildLogoGrid(List<String> logos) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: logos.map((logo) =>
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              logo,
              height: 40,
              fit: BoxFit.contain,
            ),
          )
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagedLogos = _getPagedLogos();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Text(
            'Featured Partners',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Text(
            'Domestic & International',
            style: TextStyle(
              color: TColors.grey,
            ),
          ),
        ),
        // const SizedBox(height: 16),
        SizedBox(
          height: 270, // Adjust this height based on your needs
          child: PageView.builder(
            controller: _pageController,
            itemCount: pagedLogos.length,
            itemBuilder: (context, index) => _buildLogoGrid(pagedLogos[index]),
          ),
        ),
        const SizedBox(height: 16),
        DotsIndicator(
          itemCount: pagedLogos.length,
          currentPage: _currentPage,
        ),
      ],
    );
  }
}

// widgets/dots_indicator.dart
class DotsIndicator extends StatelessWidget {
  final int itemCount;
  final int currentPage;

  const DotsIndicator({
    Key? key,
    required this.itemCount,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
            (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentPage == index
                ? TColors.primary
                : TColors.grey.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

