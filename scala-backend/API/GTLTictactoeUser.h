/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLTictactoeUser.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   tictactoe/v1
// Description:
//   This is an API
// Classes:
//   GTLTictactoeUser (0 custom class methods, 5 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLTictactoeUser
//

@interface GTLTictactoeUser : GTLObject
@property (copy) NSString *authDomain;
@property (copy) NSString *email;
@property (copy) NSString *federatedIdentity;
@property (copy) NSString *nickname;
@property (copy) NSString *userId;
@end
