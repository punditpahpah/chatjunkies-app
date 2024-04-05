import 'package:chat_junkies/util/history.dart';
import 'package:chat_junkies/widgets/round_button.dart';
import 'package:chat_junkies/util/style.dart';
import 'package:chat_junkies/pages/welcome/phone_number_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Policy extends StatefulWidget {
  const Policy({Key key}) : super(key: key);
  @override
  _Policy createState() => new _Policy();
}

class _Policy extends State {
  @override
  Future<void> initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.only(
          left: 50,
          right: 50,
          bottom: 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTitle(),
            SizedBox(
              height: 40,
            ),
            Expanded(
              child: buildContents(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Text(
      'Terms and Policy!',
      style: TextStyle(
          fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  Widget buildContents() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chatjunkies ("Chatjunkies," "we," "us," or "our") welcomes you. Thank you for choosing to access and use our service (the "Service") made available to you through our website located at the "Website" or through our mobile application (the "App").',
            style: TextStyle(height: 1.8, fontSize: 15, color: Colors.white),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'We provide access to and use of our Service subject to the following terms of service (the "Terms of Service"), which are effective as of the date stated above. By using the Service, you acknowledge that you have read, understood, and agree to be legally bound by the terms and conditions of these Terms of Service and the terms and conditions of our Privacy Policy, which is hereby incorporated by reference. Please take the time to review our Privacy Policy. If you do not agree to any terms in these Terms of Service or the Privacy Policy, then please do not use our Service.',
            style: TextStyle(height: 1.8, fontSize: 15, color: Colors.white),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'We may change these Terms of Service from time to time, and will post any changes on the Website or notify you via email, at our option, as soon as such changes are in effect. If you are using the Service on a free trial basis, then by continuing to use the Service after we make any such changes to the Terms of Service, you are deemed to have accepted such changes. Please refer back to these Terms of Service on a regular basis.',
            style: TextStyle(height: 1.8, fontSize: 15, color: Colors.white),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Access and Use',
            style: TextStyle(
              height: 1.8,
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Subject to the terms and conditions of this Agreement, Chatjunkies will provide access to and use of the Service to you or the entity which you have authority to bind to this Agreement ("Subscriber"). We will also provide access to and use of the Service to any employee of Subscriber or other individual authorized by Subscriber (each, an "Authorized User"). Subscriber acknowledges that each Authorized User must agree to these Terms of Service and the Privacy Policy prior to use and that Subscriber shall be responsible for ensuring compliance by each Authorized User with these Terms of Service and for any breach of these Terms of Service by any Authorized User.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Subscriber is solely responsible for any data or content uploaded or stored on the Service by Subscriber or any Authorized User ("Subscriber Data"). In no event shall Chatjunkies be responsible for the use or misuse of any Subscriber Data by Subscriber or any Authorized User or other third party. Subscriber warrants and represents that it either owns or has the right to provide all Subscriber Data. Subscriber hereby grants Chatjunkies a non-exclusive, transferable, royalty-free license to use the Subscriber Data to provide the Service and as otherwise described in herein or in our Privacy Policy. As stated in the Privacy Policy, we take reasonable steps to protect the Subscriber Data from loss, misuse, and unauthorized access, disclosure, alteration, or destruction. For the avoidance of doubt, in no event will we share the project information that you upload into the Service with third parties for marketing purposes.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'All right, title, and interest in and to the Service, the Website, the App, and any information, data, software, graphics, and interactive features contained therein, including all modifications, improvements, adaptations, enhancements, or translations made thereto, and all proprietary rights in any of the foregoing (collectively, "Chatjunkies Property"), shall be and remain the sole and exclusive property of Chatjunkies.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Subscriber will not, and will not permit any Authorized User or other third party to: (i) allow anyone other than an Authorized User to access or use the Service; (ii) use the Service in any way that is not expressly permitted by this Agreement, including, without limitation, reverse engineering, modifying, copying, distributing, or sublicensing the Service, or introducing into the Service any software, virus, or code; or (iii) use the Service in violation of any applicable law or regulation.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Registration',
            style: TextStyle(
              height: 1.8,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Prior to using the Service, Subscriber will be required to register for an account. During the registration process, Subscriber will select logon credentials for each Authorized User. Logon credentials can only be used by the Authorized User to whom they are assigned and cannot be shared among Authorized Users or with third parties. Subscriber is solely responsible for the confidentiality and use of all logon credentials for its account and those assigned to Authorized Users, as well as for any use or misuse of the Service using Subscriber\'s or any Authorized User\'s logon credentials. Subscriber shall notify us immediately if it becomes aware of any loss, theft or unauthorized use of any logon credentials, and we reserve the right to delete or change them at any time and for any reason.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Publicity',
            style: TextStyle(
              height: 1.8,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Each Subscriber is permitted to identify itself as a Subscriber of the Services for promotional and marketing purposes. Subscriber grants Chatjunkies a non-exclusive, non-transferrable, non-sublicensable, and royalty-free license to use and reproduce Subscriber’s name, logos, and trademarks for promotional and marketing purposes including on Chatjunkies customer lists, advertising, and website.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'In other words, we’re proud to have the quality of customers that we do. If it comes up, we may mention you!',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Term and Termination',
            style: TextStyle(
              height: 1.8,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Chatjunkies may suspend or terminate your access to and use of the Service, in whole or in part, at any time and for any reason; provided, however, that if you have purchased a subscription for the Service, Chatjunkies right to suspend or terminate your access to and use of the Service will be limited to cases where you have failed to pay the applicable subscription fees or have otherwise breached these Terms of Service, and have not cured such payment failure or other breach within 10 business days of receiving written notice of such payment failure or other breach from Chatjunkies (and provided, further that Chatjunkies may suspend your access to and use of the Service immediately without notice in the event that Chatjunkies reasonably determines that your account may cause potential harm to Chatjukies or third parties). You may terminate your account at any time upon notice to us; provided, however, that if you have purchased a subscription for the Service, your right to terminate your account before paying the full amount of fees for the subscription period that you have committed to will be limited to cases where Chatjunkies has breached these Terms of Service, and has not cured such breach within 10 business days of receiving written notice of such breach from you. In the event of suspension or termination (other than cases where Chatjunkies locks your account due to fraudulent activities or other potential harm to Chatjunkies or third parties), Chatjunkies will provide you with access to your Subscriber Data for at least 30 days following such termination. It is your responsibility to keep backup copies of the Subscriber Data.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Chatjunkies may terminate this agreement upon written notice if Chatjunkies determines, in its sole and absolute discretion, that Customer has engaged in or permitted behavior that Chatjunkies considers to be immoral, racist, or discriminatory on the basis of race, ethnicity, national origin, caste, sexual orientation, gender, gender identity, religious affiliation, age, disability, or serious disease.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'DISCLAIMERS; LIMITED WARRANTY',
            style: TextStyle(
              height: 1.8,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'THE CHATJUNKIES PROPERTY IS PROVIDED "AS IS" AND "AS AVAILABLE," AND CHATJUNKIES DOES NOT MAKE ANY WARRANTIES WITH RESPECT TO THE SAME OR OTHERWISE IN CONNECTION WITH THESE TERMS OF SERVICE AND HEREBY DISCLAIMS ANY AND ALL EXPRESS, IMPLIED, OR STATUTORY WARRANTIES, INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AVAILABILITY, ERROR-FREE OR UNINTERRUPTED OPERATION, AND ANY WARRANTIES ARISING FROM A COURSE OF DEALING, COURSE OF PERFORMANCE, OR USAGE OF TRADE. TO THE EXTENT THAT CHATJUNKIES MAY NOT AS A MATTER OF APPLICABLE LAW DISCLAIM ANY IMPLIED WARRANTY, THE SCOPE AND DURATION OF SUCH WARRANTY WILL BE THE MINIMUM PERMITTED UNDER SUCH LAW.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'LIMITATION OF LIABILITY',
            style: TextStyle(
              height: 1.8,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'IN NO EVENT WILL CHATJUNKIES BE LIABLE TO SUBSCRIBER OR ANY OTHER PARTY, INCLUDING, WITHOUT LIMITATION, ANY AUTHORIZED USER, FOR ANY INCIDENTAL, INDIRECT, CONSEQUENTIAL, SPECIAL, EXEMPLARY, OR PUNITIVE DAMAGES OF ANY KIND (INCLUDING, BUT NOT LIMITED TO, LOST REVENUES OR PROFITS) ARISING FROM OR RELATING TO THE CHATJUNKIES PROPERTY OR OTHERWISE RELATING TO THESE TERMS OF SERVICE, REGARDLESS OF WHETHER CHATJUNKIES WAS ADVISED, HAD OTHER REASON TO KNOW, OR IN FACT KNEW OF THE POSSIBILITY THEREOF. CHATJUNKIES AGGREGATE LIABILITY FOR DIRECT DAMAGES UNDER THESE TERMS OF SERVICE WILL NOT EXCEED THE TOTAL.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Indemnification',
            style: TextStyle(
              height: 1.8,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Subscriber will defend, indemnify, and hold harmless Chatjunkies and its officers, directors, managers, and employees from any and all liabilities, costs, and expenses (including, without limitation, reasonable attorneys\' fees) in connection with any third-party claim that any of the Subscriber Data: (i) infringes or misappropriates any third-party intellectual property rights, privacy or publicity rights, or any other rights; or (ii) violates any applicable laws, rules, or regulations. Chatjunkies shall promptly notify Subscriber of the claim, provided, however, that failure to provide such notice shall not relieve Subscriber of its indemnity obligations unless it is materially prejudiced thereby. Subscriber shall have control over the defense of the claim, provided that (i) Subscriber does not make any admission of liability on behalf of Chatjunkies or agree to any settlement that imposes a financial burden on Chatjunkies without Chatjunkies prior written consent; and (ii) Chatjunkies shall have the right to participate in the defense of any such claim, at its own cost, with counsel of its choice.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'General Provisions',
            style: TextStyle(
              height: 1.8,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Subscriber shall not assign these Terms of Service or any of its rights hereunder without the prior, written consent of Chatjunkies. Subject to the foregoing, this Agreement will be binding upon and inure to the benefit of the Parties hereto and their permitted successors and assigns. These Terms of Service and performance hereunder shall be construed and governed by the laws of the State of Kentucky without giving effect to conflicts of laws principles. The parties consent and agree that any and all litigation between them arising from these Terms of Service or the business relationship created hereby shall take place in the state or federal courts located in Louisville, Kentucky. Each Party irrevocably consents and submits to the jurisdiction and venue of any such courts. If any provision of these Terms of Service is deemed invalid or unenforceable, it shall be amended or replaced in the way that best reflects the original intention of the parties, and the remainder of these Terms of Service shall remain in full force and effect. These Terms of Service, together with the Privacy Policy and any pricing information made known to you at registration, constitute the final and complete agreement between the parties regarding the subject matter hereof, and supersedes any prior or contemporaneous communications, representations, or agreements between the parties, whether oral or written.',
            style: TextStyle(
              height: 1.8,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            '🏠 Launched in May 2021 by Leslie Graham',
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
