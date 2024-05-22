import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:raven_pay_assessment/core/core.dart';
import 'package:raven_pay_assessment/features/home/data/DTOs/stream_value.dart';
import 'package:raven_pay_assessment/features/home/presentation/controllers/chart_controller.dart';
import 'package:raven_pay_assessment/features/home/presentation/controllers/socket_controller.dart';
import 'package:raven_pay_assessment/features/home/presentation/widgets/timeframe_selector.dart';
import 'package:raven_pay_assessment/shared/utils/utils.dart';
import 'package:raven_pay_assessment/shared/widgets/widgets.dart';

class Charts extends HookConsumerWidget {
  const Charts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTradingView = useState(true);
    final currentTime = useState('1H');
    final candles = ref.watch(chartControllerProvider);
    final currentSymbol = ref.watch(currentSymbolStateProvider);
    final candlestick = ref.watch(candleTickerStateProvider);

    useEffect(() {
      if (currentSymbol != null) {
        ref
            .read(chartControllerProvider.notifier)
            .getCandles(
              StreamValue(
                symbol: currentSymbol,
                interval: currentTime.value.toLowerCase(),
              ),
            )
            .then((value) {
          // ignore: invalid_use_of_protected_member
          ref.read(chartControllerProvider.notifier).state = value;
          if (candlestick == null) {
            ref.read(
              socketController(
                StreamValue(
                  symbol: currentSymbol,
                  interval: currentTime.value.toLowerCase(),
                ),
              ),
            );
          }
        });
      }

      return null;
    }, [
      currentSymbol,
      currentTime.value,
    ]);

    return Column(
      children: [
        const Gap(7),
        TimeframeSelector(
          onSelected: (value) {
            currentTime.value = value;
          },
        ),
        const Gap(15),
        Divider(
          color: blackTint.withOpacity(.1),
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 9,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  if (!isTradingView.value) {
                    isTradingView.value = true;
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 13,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: isTradingView.value
                        ? context.isDarkMode()
                            ? const Color(0xff555C63)
                            : const Color(0xffCFD3D8)
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: SubText(
                      text: 'Trading view',
                      textSize: 14,
                      foreground: context.isDarkMode() ? white : blackTint2,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (isTradingView.value) {
                    isTradingView.value = false;
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 13,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: !isTradingView.value
                        ? context.isDarkMode()
                            ? const Color(0xff555C63)
                            : const Color(0xffCFD3D8)
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: SubText(
                      text: 'Depth',
                      textSize: 14,
                      foreground: context.isDarkMode() ? white : blackTint2,
                    ),
                  ),
                ),
              ),
              const Gap(5),
              SvgPicture.asset(
                ImageAssets.expand,
              )
            ],
          ),
        ),
        Divider(
          color: blackTint.withOpacity(.1),
          thickness: 1,
        ),
        if (candles.isNotEmpty)
          SizedBox(
            height: 400,
            width: double.infinity,
            child: Candlesticks(
              key: Key(currentSymbol!.symbol! + currentTime.value),
              // style: CandleSticksStyle(
              //   borderColor: blackTint2.withOpacity(.5),
              //   background: Colors.transparent,
              //   primaryBull: const Color(0xff00C076),
              //   secondaryBull: const Color(0xff25C26E),
              //   primaryBear: const Color(0xffFF6838),
              //   secondaryBear: const Color(0xffFF6838),
              //   hoverIndicatorBackgroundColor: blackTint,
              //   primaryTextColor: blackTint2,
              //   secondaryTextColor: blackTint2,
              //   mobileCandleHoverColor: blackTint,
              //   loadingColor: appBlack,
              //   toolBarColor: Colors.transparent,
              // ),
              candles: candles,
              onLoadMoreCandles: () {
                return ref
                    .read(chartControllerProvider.notifier)
                    .loadMoreCandles(
                      StreamValue(
                        symbol: currentSymbol,
                        interval: currentTime.value.toLowerCase(),
                      ),
                    );
              },
              // displayZoomActions: false,
              actions: [
                ToolBarAction(
                  width: 45,
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: SvgPicture.asset(
                      ImageAssets.arrowDown,
                      width: 25,
                      height: 25,
                    ),
                  ),
                ),
                ToolBarAction(
                  width: 60,
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: SubText(
                      text: currentSymbol.symbol!,
                      textSize: 11,
                      foreground: blackTint2,
                    ),
                  ),
                ),
                if (candlestick != null)
                  ToolBarAction(
                    width: 55,
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Row(
                        children: [
                          const SubText(
                            text: 'O ',
                            textSize: 11,
                            foreground: blackTint2,
                          ),
                          SubText(
                            text: candlestick.candle.open.formatValue(),
                            textSize: 11,
                            foreground: textGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (candlestick != null)
                  ToolBarAction(
                    width: 55,
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Row(
                        children: [
                          const SubText(
                            text: 'H ',
                            textSize: 11,
                            foreground: blackTint2,
                          ),
                          SubText(
                            text: candlestick.candle.high.formatValue(),
                            textSize: 11,
                            foreground: textGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (candlestick != null)
                  ToolBarAction(
                    width: 55,
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Row(
                        children: [
                          const SubText(
                            text: 'L ',
                            textSize: 11,
                            foreground: blackTint2,
                          ),
                          SubText(
                            text: candlestick.candle.low.formatValue(),
                            textSize: 11,
                            foreground: textGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (candlestick != null)
                  ToolBarAction(
                    width: 55,
                    onPressed: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Row(
                        children: [
                          const SubText(
                            text: 'C ',
                            textSize: 11,
                            foreground: blackTint2,
                          ),
                          SubText(
                            text: candlestick.candle.close.formatValue(),
                            textSize: 11,
                            foreground: textGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
