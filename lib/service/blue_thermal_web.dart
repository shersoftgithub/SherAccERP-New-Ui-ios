// ============================================================================
// Web print via "Mobile Print Util" (iOS App Store app)
// ----------------------------------------------------------------------------
// App: https://apps.apple.com/us/app/mobile-print-util/id1517535160
// Purpose-built for exactly this: a website hands it an HTML receipt (base64
// encoded) via a custom URL scheme, and the app prints it to a Bluetooth
// ESC/POS thermal printer. No backend endpoint, no companion app of yours
// needed — the whole flow is client-side in this one file.
//
// FLOW:
//   1. This code builds an HTML string that looks like the receipt (bold,
//      centering, a simple item table, totals, and a QR code image).
//   2. Base64-encodes that HTML.
//   3. Opens com.samathosoft.webprint://#deb64#<base64> via url_launcher.
//   4. iOS hands the link to the app (if installed) — it renders and prints
//      the HTML on the paired Bluetooth printer. If not installed, we show
//      a dialog pointing to the App Store listing.
//
// CUSTOMER-SIDE ONE-TIME SETUP (do this before relying on it in production):
//   - Install "Mobile Print Util" from the App Store.
//   - Open it once, pair/select the Bluetooth thermal printer, and pick the
//     matching driver/profile in its settings.
//   - After that, links from your website should print without further
//     taps. Test this with your actual printer before rolling out — I
//     verified the URL-scheme contract from the app's own developer site
//     and App Store listing, not hands-on with a physical printer.
//
// IMPORTANT: use launchUrlString (not launchUrl(Uri.parse(...))) — the
// app's own protocol embeds literal '#' characters as internal delimiters
// (#deb64#, #imagurl#, etc.), which Dart's Uri class would otherwise try to
// treat as a URI fragment and mis-encode.
//
// PUBSPEC: add `url_launcher: ^6.3.0` (or current) if not already present.
// ============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

const String kMobilePrintUtilScheme = 'com.samathosoft.webprint';
const String kMobilePrintUtilAppStoreUrl =
    'https://apps.apple.com/us/app/mobile-print-util/id1517535160';

// ----------------------------------------------------------------------------
// Entry point — call this in place of the old _selectBtThermalPrint on web.
// ----------------------------------------------------------------------------
Future<void> printReceiptViaMobilePrintUtil(
  BuildContext context, {
  required dynamic companySettings, // CompanyInformation
  required List<dynamic> settings, // List<CompanySettings>
  required dynamic bill, // the bill map, same shape as your printData() uses
  required String printerSize,
  required String docType, // "SALE", "SALES RETURN", etc.
}) async {
  try {
    final html = buildReceiptHtml(
      companySettings: companySettings,
      bill: bill,
      docType: docType,
    );

    final base64Html = base64Encode(utf8.encode(html));
    final urlString = '$kMobilePrintUtilScheme://#deb64#$base64Html';

    final launched = await launchUrlString(
      urlString,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      await _showInstallDialog(context);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the print app: $e')),
      );
    }
  }
}

Future<void> _showInstallDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Printer app required'),
      content: const Text(
        'To print receipts on this device, install "Mobile Print Util" from '
        'the App Store, then pair your Bluetooth printer inside it. After '
        'that, printing from this website will work automatically.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            launchUrlString(kMobilePrintUtilAppStoreUrl,
                mode: LaunchMode.externalApplication);
          },
          child: const Text('Get the app'),
        ),
      ],
    ),
  );
}

// ----------------------------------------------------------------------------
// HTML receipt builder.
// ----------------------------------------------------------------------------
// This mirrors the DEFAULT/generic branch of your existing printData() (the
// final `else` block — taxSale header, item rows, totals, message, QR).
// Your app has ~20 printerModel variants with different layouts (models 5,
// 7, 8, 9, 11–25) — this is a starting template for ONE of them so you have
// a working end-to-end example. Once you tell me which specific
// printerModel(s) your web customers will actually use, I can convert those
// exact branches to matching HTML the same way.
//
// Sizing note: keep the HTML compact. Very long receipts (many items, or an
// embedded base64 QR image) inflate the URL length passed to the app. Using
// an <img src="https://..."> pointing at a hosted QR image (rather than
// embedding the QR as base64 image data) keeps the payload much smaller and
// is what's done below.
// ----------------------------------------------------------------------------
String buildReceiptHtml({
  required dynamic companySettings,
  required dynamic bill,
  required String docType,
}) {
  final dataInformation = bill['Information'][0];
  final dataParticulars = bill['Particulars'] as List;

  final buffer = StringBuffer();

  buffer.writeln('<div style="font-family: monospace; width: 280px;">');

  // Header
  buffer.writeln(
    '<div style="text-align:center; font-weight:bold; font-size:16px;">'
    '${_esc(companySettings.name ?? '')}</div>',
  );

  final add1 = (companySettings.add1 ?? '').toString().trim();
  if (add1.isNotEmpty) {
    buffer.writeln(
      '<div style="text-align:center; font-weight:bold;">${_esc(add1)}</div>',
    );
  }
  final add2 = (companySettings.add2 ?? '').toString().trim();
  if (add2.isNotEmpty) {
    buffer.writeln(
      '<div style="text-align:center; font-weight:bold;">${_esc(add2)}</div>',
    );
  }

  final phone =
      '${companySettings.telephone ?? ''}, ${companySettings.mobile ?? ''}';
  buffer.writeln(
    '<div style="text-align:center; font-weight:bold;">Phone No: ${_esc(phone)}</div>',
  );

  buffer.writeln('<hr>');

  buffer.writeln(
    '<div style="text-align:center; font-weight:bold; font-size:14px;">'
    '${docType == 'SALES RETURN' ? 'SALES RETURN' : 'INVOICE'}</div>',
  );

  buffer.writeln(
    '<div>Voucher No: ${_esc('${dataInformation['InvoiceNo']}')}</div>',
  );
  buffer.writeln(
    '<div>Party Name: ${_esc('${dataInformation['ToName']}')}</div>',
  );

  buffer.writeln('<hr>');

  // Items table
  buffer.writeln(
    '<table style="width:100%; font-size:12px; border-collapse: collapse;">',
  );
  buffer.writeln(
    '<tr style="font-weight:bold;">'
    '<td>Item</td><td align="right">Qty</td><td align="right">Amt</td></tr>',
  );
  for (final item in dataParticulars) {
    buffer.writeln(
      '<tr>'
      '<td>${_esc('${item['itemname']}')}</td>'
      '<td align="right">${_esc('${item['Qty']}')}</td>'
      '<td align="right">${_esc('${item['Total']}')}</td>'
      '</tr>',
    );
  }
  buffer.writeln('</table>');

  buffer.writeln('<hr>');

  buffer.writeln(
    '<div style="text-align:right; font-weight:bold;">'
    'NET TOTAL: ${_esc('${dataInformation['GrandTotal']}')}</div>',
  );

  if (bill['message'] != null && bill['message'].toString().isNotEmpty) {
    buffer.writeln(
      '<div style="text-align:center;">${_esc('${bill['message']}')}</div>',
    );
  }

  // QR code: point at a hosted QR-generation URL instead of embedding a
  // base64 image, to keep the overall URL short. Swap this for your own
  // QR endpoint if you have one, or a public one like api.qrserver.com.
  final qrData = Uri.encodeComponent(
    'Invoice:${dataInformation['InvoiceNo']}|Total:${dataInformation['GrandTotal']}',
  );
  buffer.writeln(
    '<div style="text-align:center; margin-top:8px;">'
    '<img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$qrData" '
    'width="150" height="150" /></div>',
  );

  buffer.writeln('</div>');

  return buffer.toString();
}

String _esc(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

// ----------------------------------------------------------------------------
// Example of the askPrintDevice change — same branch you pointed at:
// ----------------------------------------------------------------------------
/*
askPrintDevice(
    BuildContext context,
    String title,
    CompanyInformation companySettings,
    List<CompanySettings> settings,
    var data,
    var customerModel,
    int printerType,
    int printerDevice,
    int printModel) {
  if (printerType == 2) {
    if (printerDevice == 6) {
      // Thermal — web now hands off to the Mobile Print Util app instead
      // of trying (and failing) to use Web Bluetooth.
      printReceiptViaMobilePrintUtil(
        context,
        companySettings: companySettings,
        settings: settings,
        bill: data,
        printerSize: paperSize.toString(),
        docType: 'SALE', // whatever this call site's doc type is
      );
    }
    // ... other printerDevice branches unchanged ...
  }
  // ... other printerType branches unchanged ...
}
*/