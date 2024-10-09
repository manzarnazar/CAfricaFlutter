import 'package:flutter_grocery/features/home/screens/home_item_screen.dart';
import 'package:flutter_grocery/features/profile/screens/profile_screen.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/features/cart/screens/cart_screen.dart';
import 'package:flutter_grocery/features/category/screens/all_categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/providers/localization_provider.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_slider_list_widget.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/title_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/category/providers/category_provider.dart';
import 'package:flutter_grocery/features/home/providers/banner_provider.dart';
import 'package:flutter_grocery/features/home/providers/flash_deal_provider.dart';
import 'package:flutter_grocery/features/home/widgets/all_product_list_widget.dart';
import 'package:flutter_grocery/features/home/widgets/banners_widget.dart';
import 'package:flutter_grocery/features/home/widgets/category_web_widget.dart';
import 'package:flutter_grocery/features/home/widgets/flash_deal_home_card_widget.dart';
import 'package:flutter_grocery/features/home/widgets/home_item_widget.dart';
import 'package:flutter_grocery/features/order/screens/order_list_screen.dart';
import 'package:flutter_grocery/features/order/screens/order_search_screen.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/product_type.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Future<void> loadData(bool reload, BuildContext context,
      {bool fromLanguage = false}) async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final flashDealProvider =
        Provider.of<FlashDealProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final withLListProvider =
        Provider.of<WishListProvider>(context, listen: false);
    final localizationProvider =
        Provider.of<LocalizationProvider>(context, listen: false);

    ConfigModel config =
        Provider.of<SplashProvider>(context, listen: false).configModel!;
    if (reload) {
      Provider.of<SplashProvider>(context, listen: false).initConfig();
    }
    if (fromLanguage &&
        (authProvider.isLoggedIn() || config.isGuestCheckout!)) {
      localizationProvider.changeLanguage();
    }
    Provider.of<CategoryProvider>(context, listen: false)
        .getCategoryList(context, reload);

    Provider.of<BannerProvider>(context, listen: false)
        .getBannerList(context, reload);

    if (productProvider.dailyProductModel == null) {
      productProvider.getItemList(1,
          isUpdate: false, productType: ProductType.dailyItem);
    }

    if (productProvider.wholesaleProductModel == null) {
      productProvider.getItemList(1,
          isUpdate: false, productType: ProductType.wholesaleItem);
    }
    if (productProvider.wholesaleProductModel == null) {
      productProvider.getItemList(1,
          isUpdate: false, productType: ProductType.collaborationItem);
    }

    if (productProvider.featuredProductModel == null) {
      productProvider.getItemList(1,
          isUpdate: false, productType: ProductType.featuredItem);
    }

    if (productProvider.mostViewedProductModel == null) {
      productProvider.getItemList(1,
          isUpdate: false, productType: ProductType.mostReviewed);
    }

    productProvider.getAllProductList(1, reload, isUpdate: false);

    if (authProvider.isLoggedIn()) {
      withLListProvider.getWishListProduct();
    }

    if ((config.flashDealProductStatus ?? false) &&
        flashDealProvider.flashDealModel == null) {
      flashDealProvider.getFlashDealProducts(1, isUpdate: false);
    }
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  late MotionTabBarController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = MotionTabBarController(length: 4, vsync: this); // 5 tabs
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashProvider>(builder: (context, splashProvider, child) {
      return RefreshIndicator(
          onRefresh: () async {
            await HomeScreen.loadData(true, context);
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: Scaffold(
              appBar: ResponsiveHelper.isDesktop(context)
                  ? const PreferredSize(
                      preferredSize: Size.fromHeight(120),
                      child: WebAppBarWidget())
                  : null,
              bottomNavigationBar: MotionTabBar(
                controller: _tabController,
                initialSelectedTab: "Home",
                labels: const [
                  "Home",
                  "Waitlist Items",
                  "Collaboration",
                  "Profile",
                ], // 5 labels
                icons: const [
                  Icons.home_outlined,
                  Icons.receipt_long_sharp,
                  Icons.format_list_bulleted_add,
                  Icons.person_2_outlined,
                ], // 5 icons
                tabSize: 40,
                tabBarHeight: 55,
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                tabIconColor: Colors.white,
                tabIconSize: 25.0,
                tabIconSelectedSize: 22.0,
                tabSelectedColor: Colors.white,
                tabIconSelectedColor: Theme.of(context).primaryColor,
                tabBarColor: Theme.of(context).primaryColor,
                onTabItemSelected: (int index) {
                  setState(() {
                    _tabController?.index = index;
                  });
                },
              ),
              body: TabBarView(
                  controller: _tabController, // Use the TabController here
                  children: [
                    CustomScrollView(controller: scrollController, slivers: [
                      SliverToBoxAdapter(
                          child: Center(
                              child: SizedBox(
                        width: Dimensions.webScreenWidth,
                        child: Column(children: [
                          Consumer<BannerProvider>(
                              builder: (context, banner, child) {
                            return (banner.bannerList?.isEmpty ?? false)
                                ? const SizedBox()
                                : const BannersWidget();
                          }),

                          /// Category
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.paddingSizeLarge
                                  : Dimensions.paddingSizeSmall,
                            ),
                            child: const CategoryWidget(),
                          ),

                          /// Flash Deal
                          if (splashProvider
                                  .configModel?.flashDealProductStatus ??
                              false)
                            const FlashDealHomeCardWidget(),

                          Consumer<ProductProvider>(
                              builder: (context, productProvider, child) {
                            bool isDalyProduct =
                                (productProvider.dailyProductModel == null ||
                                    (productProvider.dailyProductModel?.products
                                            ?.isNotEmpty ??
                                        false));
                            bool isFeaturedProduct =
                                (productProvider.featuredProductModel == null ||
                                    (productProvider.featuredProductModel
                                            ?.products?.isNotEmpty ??
                                        false));
                            bool isMostViewedProduct =
                                (productProvider.mostViewedProductModel ==
                                        null ||
                                    (productProvider.mostViewedProductModel
                                            ?.products?.isNotEmpty ??
                                        false));
                            bool isWholesaleProduct =
                                (productProvider.wholesaleProductModel ==
                                        null ||
                                    (productProvider.wholesaleProductModel
                                            ?.products?.isNotEmpty ??
                                        false));
                            print(
                                "objectadada ${productProvider.collaborationProductModel != null}");

                            return Column(children: [
                              isDalyProduct
                                  ? Column(children: [
                                      TitleWidget(
                                          title: getTranslated(
                                              'Available Dar', context),
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context,
                                                RouteHelper.getHomeItemRoute(
                                                    ProductType.dailyItem));
                                          }),
                                      HomeItemWidget(
                                          productList: productProvider
                                              .dailyProductModel?.products,
                                          dailyneed: true),
                                    ])
                                  : const SizedBox(),
                              // if ((splashProvider.configModel?.featuredProductStatus ??
                              //         false) &&
                              //     isFeaturedProduct)
                              //   Column(children: [
                              //     TitleWidget(
                              //         title: getTranslated(
                              //             ProductType.featuredItem, context),
                              //         onTap: () {
                              //           Navigator.pushNamed(
                              //               context,
                              //               RouteHelper.getHomeItemRoute(
                              //                   ProductType.featuredItem));
                              //         }),
                              //     HomeItemWidget(
                              //         productList:
                              //             productProvider.featuredProductModel?.products,
                              //         isFeaturedItem: true),
                              //   ]),
                              Column(children: [
                                TitleWidget(
                                  title: getTranslated(
                                      "Collaboration / Full Order", context),
                                ),
                              ]),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    // Collaboration Container
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context,
                                              RouteHelper.getHomeItemRoute(
                                                  ProductType
                                                      .collaborationItem));
                                          // Add your navigation or logic here
                                        },
                                        child: Container(
                                          height:
                                              50, // You can adjust the height if needed
                                          padding: EdgeInsets.only(left: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                Images.collboration,
                                                width: 30,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Collaboration',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                        width:
                                            10), // Spacing between containers

                                    // Full Order Container
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context,
                                              RouteHelper.getHomeItemRoute(
                                                  ProductType.wholesaleItem));

                                          // Add your navigation or logic here
                                        },
                                        child: Container(
                                          height:
                                              50, // Same height as the other container
                                          padding: EdgeInsets.only(left: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                Images.fullOrder,
                                                width: 30,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Full Order',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Column(children: [
                              //   TitleWidget(
                              //       title: getTranslated(
                              //           "Collaboration Items", context),
                              //       onTap: () {
                              //         Navigator.pushNamed(
                              //             context,
                              //             RouteHelper.getHomeItemRoute(
                              //                 ProductType.collaborationItem));
                              //       }),
                              //   HomeItemWidget(
                              //     productList: productProvider
                              //         .collaborationProductModel?.products,
                              //   ),
                              // ]),
                              // Column(children: [
                              //   TitleWidget(
                              //       title: getTranslated(
                              //           "Wholesale Items", context),
                              //       onTap: () {
                              //         Navigator.pushNamed(
                              //             context,
                              //             RouteHelper.getHomeItemRoute(
                              //                 ProductType.wholesaleItem));
                              //       }),
                              //   HomeItemWidget(
                              //     productList: productProvider
                              //         .wholesaleProductModel?.products,
                              //   ),
                              // ]),
                              if ((splashProvider.configModel
                                          ?.mostReviewedProductStatus ??
                                      false) &&
                                  isMostViewedProduct)
                                Column(children: [
                                  TitleWidget(
                                      title: getTranslated(
                                          ProductType.mostReviewed, context),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context,
                                            RouteHelper.getHomeItemRoute(
                                                ProductType.mostReviewed));
                                      }),
                                  HomeItemWidget(
                                      productList: productProvider
                                          .mostViewedProductModel?.products),
                                ])
                            ]);
                          }),

                          ResponsiveHelper.isMobilePhone()
                              ? const SizedBox(height: 10)
                              : const SizedBox.shrink(),

                          AllProductListWidget(
                              scrollController: scrollController),
                        ]),
                      ))),
                      const FooterWebWidget(footerType: FooterType.sliver),
                    ]),
                    HomeItemScreen(
                      productType: ProductType.wholesaleItem,
                      isFromNav: true,
                    ),
                    HomeItemScreen(
                      productType: ProductType.collaborationItem,
                      isFromNav: true,
                    ),
                    ProfileScreen(
                      isFromNav: true,
                    )
                  ])));
    });
  }
}
