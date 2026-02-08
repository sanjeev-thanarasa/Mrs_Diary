import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/homeProductList.dart';
import 'package:mrs_dth_diary_v1/scr/providers/village.dart';
import 'package:provider/provider.dart';

import 'customText.dart';
import 'loading.dart';
import 'subHelpers/responsive.dart';

class HomeCard extends StatefulWidget {
  final BuildContext? context;

  const HomeCard({super.key, this.context});

  @override
  _HomeCardState createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  double? windowWidth;
  double? windowHeight;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final villageProvider = Provider.of<VillageProvider>(context);
    final size = MediaQuery.sizeOf(context);
    windowWidth = size.width;
    windowHeight = size.height;
    final rs = context.rs;
    final isLandscape = size.width > size.height;
    final crossAxisCount = size.width >= 900
        ? 4
        : size.width >= 600
            ? 3
            : 2;
    final aspectRatio = isLandscape ? 1.3 : 1.05;
    if (villageProvider.isLoading) {
      return const LoadingShimmerGrid();
    }
    return GridView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: rs.rh(0)),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: rs.rh(12),
        crossAxisSpacing: rs.rw(12),
        childAspectRatio: aspectRatio,
      ),
      itemCount: homeProductList.length,
      itemBuilder: (context, index) {
        final item = homeProductList[index];
        return _DashboardTile(
          title: item.text,
          image: item.image,
          count: lengthCounter(item.text, villageProvider),
          onTap: () => item.onTapCard(context),
        );
      },
    );
  }

  lengthCounter(
    String title,
    VillageProvider villageProvider,
  ) {
    if (title == "கிராமங்கள்") {
      return villageProvider.villageCount;
    } else if (title == "பழைய பயனர்கள்") {
      return villageProvider.totalOldCustomersCount;
    } else if (title == "புதிய பயனர்கள்") {
      return villageProvider.totalNewCustomersCount;
    } else if (title == "இன்று பணம் தர வேண்டியவர்கள்") {
      return villageProvider.todayPaymentCount;
    } else if (title == "இன்று Recharge முடியும் நபர்கள்") {
      return villageProvider.todayExpiredCount;
    } else if (title == "கொடுமதிகள்") {
      return villageProvider.totalBalanceCount;
    } else if (title == "தருமதிகள்") {
      return villageProvider.totalPendingCount;
    } else if (title == "பணம் தந்தவர்கள்") {
      return villageProvider.totalPaidCount;
    } else {
      return 0;
    }
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.title,
    required this.image,
    required this.count,
    required this.onTap,
  });

  final String title;
  final String image;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rs = context.rs;
    return Card(
      elevation: rs.r(0.8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs.r(20))),
      child: InkWell(
        borderRadius: BorderRadius.circular(rs.r(20)),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(rs.r(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(rs.r(20)),
            border: Border.all(color: colorScheme.outlineVariant),
            gradient: LinearGradient(
              colors: [
                colorScheme.surface,
                colorScheme.surfaceVariant.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: rs.r(48),
                    width: rs.r(48),
                    padding: EdgeInsets.all(rs.r(6)),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(rs.r(14)),
                    ),
                    child: Image.asset(
                      image,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (count > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rs.rw(10),
                        vertical: rs.rh(4),
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(rs.r(20)),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: rs.sp(12),
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      size: rs.r(22),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: rs.rh(4)),
              Text(
                'விரிவாக பார்க்க',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
