import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/cart/widgets/cart_item_widget.dart';
import 'package:provider/provider.dart';

class CartProductListWidget extends StatelessWidget {
  final int isWholesale;

  const CartProductListWidget({
    Key? key,
    this.isWholesale = 0, // Set default value to 0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cartProvider, _) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: cartProvider.cartList
            .where((item) => item.isWholesale == isWholesale)
            .length,
        itemBuilder: (context, index) {
          final retailList = cartProvider.cartList
              .where((item) => item.isWholesale == isWholesale)
              .toList();
          return CartItemWidget(
            cart: retailList[index],
            index: index,
          );
        },
      );
    });
  }
}
