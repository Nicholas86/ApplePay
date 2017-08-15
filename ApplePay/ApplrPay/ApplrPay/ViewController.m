//
//  ViewController.m
//  ApplrPay
//
//  Created by lanouhn on 16/6/5.
//  Copyright © 2016年 lanouhn. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>//引入系统框架
@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //支付按钮苹果自带
    //引入系统框架#import <PassKit/PassKit.h>
    //1.创建支付专用按钮
    PKPaymentButton  *payButton = [PKPaymentButton  buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
    payButton.center = self.view.center;
    [payButton  addTarget:self action:@selector(handlePay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:payButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//支付按钮触发事件
- (void)handlePay:(UIButton *)sender{
    NSLog(@"苹果支付");
    
    //1.判断设备是否支持Apple Pay
    if ([PKPaymentAuthorizationViewController  canMakePayments]) {
        //设备支持
        //1.1创建支付请求类
        PKPaymentRequest *request = [[PKPaymentRequest  alloc] init];
        //1.2设置地区的 HK 大陆
        request.countryCode = @"CN";
        //1.3设置币种 币种 cny大陆
        request.currencyCode = @"CNY";
        
        //1.4限制支付卡 商家所支持的卡类型
        //PKEncryptionSchemeECC_V2
        //PKPaymentNetworkAmex  美国运通卡
        //PKPaymentNetworkChinaUnionPay    中国银联卡必须用
        //PKPaymentNetworkDiscover
        //PKPaymentNetworkInterac
        //PKPaymentNetworkMasterCard  万事达信用卡
        //PKPaymentNetworkPrivateLabel
        //PKPaymentNetworkVisa    Visa卡
        request.supportedNetworks = @[PKEncryptionSchemeECC_V2,PKPaymentNetworkAmex,PKPaymentNetworkChinaUnionPay,PKPaymentNetworkDiscover,PKPaymentNetworkInterac,PKPaymentNetworkMasterCard,PKPaymentNetworkPrivateLabel,PKPaymentNetworkVisa];
        
        //1.5商家的支付能力
        //PKMerchantCapability3DS  官方要求必须支持
        //PKMerchantCapabilityEMV :中国银联,Visa卡,万事达信用卡
        request.merchantCapabilities = PKMerchantCapability3DS | PKMerchantCapabilityEMV | PKMerchantCapabilityCredit |  PKMerchantCapabilityDebit;
        request.merchantIdentifier = @"merchant.com.lanou3g.hanshanhuPaY"; //商家id 开发者中心力创建的id
        //1.6需要的配送信息,以及账单信息
        request.requiredBillingAddressFields = PKAddressFieldAll;
        request.requiredShippingAddressFields = PKAddressFieldAll;
        //1.7运输方式
        NSDecimalNumber *shipNumberPrice = [NSDecimalNumber  decimalNumberWithString:@"11.0"]; //给快递公司的钱
        PKShippingMethod *method = [PKShippingMethod  summaryItemWithLabel:@"快递公司" amount:shipNumberPrice];
        method.detail = @"24小时到达";
        method.identifier = @"kuaidi"; //快递公司的标识 运通,申通
        
        request.shippingMethods = @[method];//快递公司配置信息
        request.shippingType = PKShippingTypeStorePickup;
        //1.8额外的信息
        //applicationData 这个存储一些你的应用中,关于支付的唯一标识信息,比如:一个购物车中的商品id 在用户授权后这个applicationData的哈希值就会出现在这次支付的token中
        request.applicationData = [@"商品ID:123456" dataUsingEncoding:NSUTF8StringEncoding];
        //1.9商品的支付页面
        PKPaymentSummaryItem *item1 = [PKPaymentSummaryItem  summaryItemWithLabel:@"立得" amount:[NSDecimalNumber  decimalNumberWithString:@"10.0"]];
        
        PKPaymentSummaryItem *item2 = [PKPaymentSummaryItem  summaryItemWithLabel:@"立得" amount:[NSDecimalNumber  decimalNumberWithString:@"10.0"]];
        
        PKPaymentSummaryItem *item3 = [PKPaymentSummaryItem  summaryItemWithLabel:@"中石油" amount:[NSDecimalNumber  decimalNumberWithString:@"30.0"]];
        request.paymentSummaryItems = @[item1,item2,item3];
        //2.0显示支付页面
        PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController  alloc] initWithPaymentRequest:request];
        vc.delegate = self;//VC的代理  执行协议
        [self  presentViewController:vc animated:YES completion:nil];
        
        
    }else{
        NSLog(@"");
    }
    
}
#pragma PKPaymentAuthorizationViewControllerDelegate
//最重要的方法 支付过程中
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion{
    //payment:代表支付的对象,支付的信都在它身上. 1.1.token 当时创建这个payment的时候,都可以在拿到, 信息,价格,地址,快递公司,描述,都可以
    
    //PKPaymentAuthorizationStatus :认证状态
 //    PKPaymentAuthorizationStatusSuccess, 交易成功
//    PKPaymentAuthorizationStatusFailure, 交易失败 PKPaymentAuthorizationStatusInvalidBillingPostalAddress, 没有授权交易或者说认证失败
    //PKPaymentAuthorizationStatusInvalidShippingPostalAddress, 拒绝收货地址
    // PKPaymentAuthorizationStatusInvalidShippingContact,   提供信息不足
//    PKPaymentAuthorizationStatusPINRequired NS_ENUM_AVAILABLE(NA, 9_2),输入指纹
//    PKPaymentAuthorizationStatusPINIncorrect NS_ENUM_AVAILABLE(NA, 9_2),指纹输入不正确
//    PKPaymentAuthorizationStatusPINLockout NS_ENUM_AVAILABLE(NA, 9_2)    输入次数超出

    
    //completion 一个block 直接影响支付结果
    
    PKPaymentToken *token = payment.token;
    NSLog(@"%@",token);
    //订单地址
    NSString *address = payment.billingContact.postalAddress.city;
    NSLog(@"%@",address);
    //这个位置需要开发人员 把token值以及支付订单的信息上传到公司的服务器,也就是调用下公司的后台数据接口,进行请求信息 .  根据后台返给我们的支付信息(成功,失败)- 调用block -- completion
    BOOL paySucess = YES; //相当于后台返回给我们的支付结果状态码500 302
    if (paySucess) {
        //成功
        completion(PKPaymentAuthorizationStatusSuccess);
    }else{//失败
        completion(PKPaymentAuthorizationStatusFailure);
    }
}


- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
    //点击右上角的取消按钮
    NSLog(@"点击右上角的取消按钮");
    [self  dismissViewControllerAnimated:YES completion:nil];
}


@end














