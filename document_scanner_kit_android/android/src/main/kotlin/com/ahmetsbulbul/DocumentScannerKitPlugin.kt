package com.ahmetsbulbul

import android.app.Activity
import android.content.Intent
import android.content.IntentSender
import android.util.Log
import androidx.annotation.NonNull
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class DocumentScannerKitPlugin : FlutterPlugin, ActivityAware {
    private lateinit var handler: DocumentScannerKitHandler
    private lateinit var channel: MethodChannel
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        handler = DocumentScannerKitHandler()
        channel = MethodChannel(binding.binaryMessenger, "document_scanner_kit_android")
        channel.setMethodCallHandler(handler)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        handler.setActivityPluginBinding(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}
}

class DocumentScannerKitHandler: MethodCallHandler, PluginRegistry.ActivityResultListener {
    private lateinit var binding: ActivityPluginBinding;
    private val SCAN_REQUEST_CODE = 1
    private var pendingResult: Result? = null

    fun setActivityPluginBinding(binding: ActivityPluginBinding) {
        this.binding = binding
        binding.addActivityResultListener(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformName") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "scan") {
            Log.i("DocumentScannerKit","scan method called")
            scan(result);
        } else
        {
            result.notImplemented()
        }
    }

    private fun scan(@NonNull result: Result) {
        this.pendingResult = result
        Log.i("DocumentScannerKit","scan method running")
        try {
            val options = GmsDocumentScannerOptions.Builder()
                // SCANNER_MODE_BASE: basic editing capabilities
                // SCANNER_MODE_BASE_WITH_FILTER: adds image filters (grayscale, auto image enhancement, etc...)
                // SCANNER_MODE_FULL(default): adds ML-enabled image cleaning capabilities. This mode will also allow future major features to be automatically added along with Google Play services updates, while the other two modes will maintain their current feature sets and only receive minor refinements.
                // More info: https://developers.google.com/ml-kit/vision/doc-scanner
                .setScannerMode(GmsDocumentScannerOptions.SCANNER_MODE_BASE)
                .setGalleryImportAllowed(true)
                // TODO: Result format should be configurable
                .setResultFormats(GmsDocumentScannerOptions.RESULT_FORMAT_JPEG)
                // TODO: Not sure but it can be also configurable
//                .setPageLimit(10)
                .build()
            val activity = binding.activity
            GmsDocumentScanning.getClient(options)
                .getStartScanIntent(activity)
                .addOnSuccessListener { intentSender: IntentSender ->
                    try {
                        Log.i("DocumentScannerKit","Starting intent sender")
                        activity.startIntentSenderForResult(
                            intentSender,
                            SCAN_REQUEST_CODE,
                            null,
                            0,
                            0,
                            0
                        )
                    } catch (e: IntentSender.SendIntentException) {
                        Log.e("DocumentScannerKit","Error: $e")
                        e.printStackTrace()
                        throw e;
                    }
                }
        } catch (e: Exception) {
            Log.e("DocumentScannerKit","Error: $e")
            e.printStackTrace()
            throw e;
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        Log.i("DocumentScannerKit","onActivityResult")
        if (requestCode == SCAN_REQUEST_CODE) {
            Log.i("DocumentScannerKit","Request code is SCAN_REQUEST_CODE")
            if (resultCode == Activity.RESULT_OK) {
                Log.i("DocumentScannerKit","Activity ended with RESULT_OK")
                val result = GmsDocumentScanningResult.fromActivityResultIntent(data)
                if (result != null) {
                    // TODO: pdf handler if needed
                    println("Result is not null")

                    val pages = result.pages
                    if (!pages.isNullOrEmpty()) {
                        var paths: ArrayList<String> = arrayListOf()
                        for (page in pages) {
                            Log.i("DocumentScannerKit","Page image uri: ${page.imageUri}")
                            Log.i("DocumentScannerKit","Page image uri path: ${page.imageUri.path}")
//                            println(page.imageUri.path)
                            paths.add(page.imageUri.path!!)
                        }
                        this.pendingResult?.success(paths.toList())
                        return true
                    } else {
                        this.pendingResult?.error("Error", "Pages are null or empty", null)

                    }
                } else {
                    this.pendingResult?.error("Error", "Result is null", null)

                }

            } else {
                Log.i("DocumentScannerKit","Activity ended with $resultCode")
                this.pendingResult?.error("Error", "Activity ended with $resultCode", null)

            }
        }
        return false
    }
}
