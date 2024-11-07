require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.to_s + '/swagger'

  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Home budget API',
        version: 'v1'
      },
      paths: {
        '/users/me' => {
          get: {
            tags: ['User'],
            summary: 'Retrieve current user profile',
            operationId: 'getCurrentUserProfile',
            security: [{ Bearer: [] }],
            responses: {
              '200': {
                description: 'Current user profile fetched successfully',
                content: {
                  'application/json': {
                    schema: { '$ref' => '#/components/schemas/user' }
                  }
                }
              },
              '401': {
                description: 'Unauthorized',
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        status: { type: :integer },
                        message: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        '/users/update' => {
          put: {
            tags: ['User'],
            summary: 'Update user profile',
            operationId: 'updateUserProfile',
            security: [{ Bearer: [] }],
            requestBody: {
              required: true,
              content: {
                'application/json': {
                  schema: {
                    type: :object,
                    properties: {
                      first_name: { type: :string },
                      last_name: { type: :string },
                      email: { type: :string, format: :email },
                      password: { type: :string },
                      password_confirmation: { type: :string }
                    }
                  }
                }
              }
            },
            responses: {
              '200': {
                description: 'User profile updated successfully',
                content: {
                  'application/json': {
                    schema: { '$ref' => '#/components/schemas/user' }
                  }
                }
              },
              '422': {
                description: 'Invalid data provided',
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        status: { type: :integer },
                        message: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        '/users/reset_remaining_budget' => {
          post: {
            tags: ['User'],
            summary: 'Manually reset the user remainig budget',
            operationId: 'resetUserBudget',
            security: [{ Bearer: [] }],
            responses: {
              '200': {
                description: 'User budget reset successfully',
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        status: { type: :string },
                        message: { type: :string },
                        new_budget: { type: :number }
                      }
                    }
                  }
                }
              },
              '401': {
                description: 'Unauthorized',
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        status: { type: :integer },
                        message: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        '/users/sign_up' => {
          post: {
            tags: ['Authentication'],
            summary: 'Sign up a new user',
            operationId: 'signUpUser',
            requestBody: {
              required: true,
              content: {
                'application/json': {
                  schema: {
                    type: :object,
                    properties: {
                      email: { type: :string, format: :email },
                      password: { type: :string },
                      first_name: { type: :string },
                      last_name: { type: :string }
                    },
                    required: ['email', 'password', 'first_name', 'last_name']
                  }
                }
              }
            },
            responses: {
              '200': {
                description: 'User signed up successfully',
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        status: {
                          type: :object,
                          properties: {
                            code: { type: :integer },
                            message: { type: :string }
                          }
                        },
                        data: {
                          type: :object,
                          properties: {
                            email: { type: :string },
                            first_name: { type: :string },
                            last_name: { type: :string }
                          }
                        }
                      }
                    }
                  }
                }
              },
              '422': {
                description: 'Unprocessable entity',
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        status: {
                          type: :object,
                          properties: {
                            message: { type: :string }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        '/users/sign_in' => {
          post: {
            tags: ['Authentication'],
            summary: 'Log in a user',
            operationId: 'loginUser',
            requestBody: {
              required: true,
              content: {
                'application/json': {
                  schema: {
                    type: :object,
                    properties: {
                      email: { type: :string, format: :email },
                      password: { type: :string }
                    },
                    required: ['email', 'password']
                  }
                }
              }
            },
            responses: {
              '200': {
                description: 'Logged in successfully, returns JWT token',
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        status: {
                          type: :object,
                          properties: {
                            code: { type: :integer },
                            message: { type: :string }
                          }
                        },
                        data: {
                          type: :object,
                          properties: {
                            user: {
                              type: :object,
                              properties: {
                                email: { type: :string },
                                first_name: { type: :string },
                                last_name: { type: :string }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              '401': {
                description: 'Unauthorized - Invalid credentials',
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        status: {
                          type: :object,
                          properties: {
                            message: { type: :string }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        '/users/sign_out' => {
          delete: {
            tags: ['Authentication'],
            summary: 'Log out a user',
            operationId: 'logoutUser',
            security: [{ Bearer: [] }],
            responses: {
              '200': {
                description: 'Logged out successfully',
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        status: {
                          type: :object,
                          properties: {
                            code: { type: :integer },
                            message: { type: :string }
                          }
                        }
                      }
                    }
                  }
                }
              },
              '401': {
                description: 'Unauthorized - No active session',
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        status: {
                          type: :object,
                          properties: {
                            message: { type: :string }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      components: {
        schemas: {
          user: {
            type: :object,
            properties: {
              id: { type: :integer },
              first_name: { type: :string },
              last_name: { type: :string },
              email: { type: :string, format: :email },
              remaining_budget: { type: :number, format: :float },
              maximum_budget: { type: :number, format: :float },
              remaining_budget_reset_date: { type: :string, format: :date },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['first_name', 'last_name', 'email', 'remaining_budget', 'maximum_budget', 'remaining_budget_reset_date']
          },
          expense: {
            type: :object,
            properties: {
              id: { type: :integer },
              description: { type: :string },
              amount: { type: :number },
              date: { type: :string, format: :date },
              category_id: { type: :integer },
              user_id: { type: :integer }
            },
            required: ['description', 'amount', 'date', 'category_id', 'user_id'],
            example: {
              id: 1,
              description: "Grocery Shopping",
              amount: 45.99,
              date: "2024-01-15",
              category_id: 1,
              user_id: 1
            }
          },
          category: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['name'],
            example: {
              id: 1,
              name: "Groceries",
              created_at: "2024-01-01T00:00:00Z",
              updated_at: "2024-01-01T00:00:00Z"
            }
          }
        },
        responses: {
          UnprocessableEntity: {
            description: 'Unprocessable Entity',
            content: {
              'application/json': {
                schema: {
                  type: :object,
                  properties: {
                    errors: {
                      type: :array,
                      items: { type: :string }
                    }
                  }
                },
                example: { errors: ['Name can\'t be blank'] }
              }
            }
          },
          NotFound: {
            description: 'Not Found',
            content: {
              'application/json': {
                schema: {
                  type: :object,
                  properties: {
                    error: { type: :array, items: { type: :string } }
                  }
                },
                example: { error: ['Not Found'] }
              }
            }
          },
          BadRequest: {
            description: 'Bad Request',
            content: {
              'application/json': {
                schema: {
                  type: :object,
                  properties: {
                    error: { type: :array, items: { type: :string } }
                  }
                },
                example: { error: ['param is missing or the value is empty: param_name'] }
              }
            }
          }
        },
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT
          }
        }
      }
    }
  }
end
