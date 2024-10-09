import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';

class QuantityButtonWidget extends StatelessWidget {
  final bool isIncrement;
  final int quantity;
  final bool isCartWidget;
  final int? stock;
  final int? maxOrderQuantity;
  final int? cartIndex;
  final int isWholesale;
  final int wholesaleMinQty;
  final int wholesaleMaxQty;

  const QuantityButtonWidget({
    Key? key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.maxOrderQuantity,
    this.isCartWidget = false,
    this.wholesaleMaxQty = 0,
    this.wholesaleMinQty = 0,
    required this.cartIndex,
    required this.isWholesale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return InkWell(
      onTap: () {
        if (cartIndex != null) {
          if (isIncrement) {
            if (isWholesale == 1) {
              // Wholesale quantity increment logic
              if (cartProvider.cartList[cartIndex!].quantity! <
                  wholesaleMaxQty) {
                if (cartProvider.cartList[cartIndex!].quantity! < stock!) {
                  cartProvider.setCartQuantity(true, cartIndex,
                      showMessage: true, context: context);
                } else {
                  showCustomSnackBarHelper(
                      getTranslated('out_of_stock', context));
                }
              } else {
                showCustomSnackBarHelper(
                    '${getTranslated('you_can_add_max', context)} $wholesaleMaxQty ${getTranslated('items_only', context)}');
              }
            } else {
              // Regular quantity increment logic
              if (maxOrderQuantity == null ||
                  cartProvider.cartList[cartIndex!].quantity! <
                      maxOrderQuantity!) {
                if (cartProvider.cartList[cartIndex!].quantity! < stock!) {
                  cartProvider.setCartQuantity(true, cartIndex,
                      showMessage: true, context: context);
                } else {
                  showCustomSnackBarHelper(
                      getTranslated('out_of_stock', context));
                }
              } else {
                showCustomSnackBarHelper(
                    '${getTranslated('you_can_add_max', context)} $maxOrderQuantity ${getTranslated(maxOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
              }
            }
          } else {
            if (cartProvider.cartList[cartIndex!].quantity! > 1) {
              cartProvider.setCartQuantity(false, cartIndex,
                  showMessage: true,
                  context: context,
                  isWholesale: isWholesale,
                  wholesaleMinQty: wholesaleMinQty);
            } else {
              cartProvider.setExistData(null);
              cartProvider.removeItemFromCart(cartIndex!, context);
            }
          }
        } else {
          if (!isIncrement && quantity > 1) {
            if (isWholesale == 1) {
              if (wholesaleMinQty < quantity) {
                cartProvider.setQuantity(false);
              } else {
                if (stock! < wholesaleMinQty) {
                  cartProvider.setQuantity(false);
                } else {
                  showCustomSnackBarHelper(getTranslated(
                      'Minimum Quantity is: stock ${stock}', context));
                }
                showCustomSnackBarHelper(getTranslated(
                    'Minimum Quantity is: ${wholesaleMinQty}', context));
              }
            } else {
              cartProvider.setQuantity(false);
            }
          } else if (isIncrement) {
            if (isWholesale == 1) {
              // Wholesale check without cartIndex
              if (quantity < wholesaleMaxQty) {
                if (quantity < stock!) {
                  cartProvider.setQuantity(true);
                } else {
                  showCustomSnackBarHelper(
                      getTranslated('out_of_stock', context));
                }
              } else {
                showCustomSnackBarHelper(
                    '${getTranslated('you_can_add_max', context)} $wholesaleMaxQty ${getTranslated('items_only', context)}');
              }
            } else {
              // Regular quantity increment logic without cartIndex
              if (maxOrderQuantity == null || quantity < maxOrderQuantity!) {
                if (quantity < stock!) {
                  cartProvider.setQuantity(true);
                } else {
                  showCustomSnackBarHelper(
                      getTranslated('out_of_stock', context));
                }
              } else {
                showCustomSnackBarHelper(
                    '${getTranslated('you_can_add_max', context)} $maxOrderQuantity ${getTranslated(maxOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
              }
            }
          }
        }
      },
      child: ResponsiveHelper.isDesktop(context)
          ? Container(
              // padding: EdgeInsets.all(3),
              height: 30, width: 40,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Icon(
                  isIncrement ? Icons.add : Icons.remove,
                  color: isIncrement
                      ? Theme.of(context).primaryColor
                      : quantity > 1
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor,
                  size: isCartWidget ? 26 : 20,
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(3),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Icon(
                isIncrement ? Icons.add : Icons.remove,
                color: isIncrement
                    ? Theme.of(context).primaryColor
                    : quantity > 1
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor,
                size: isCartWidget ? 26 : 20,
              ),
            ),
    );
  }
}
