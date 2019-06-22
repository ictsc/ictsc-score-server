export default (error, context) => {
  // TODO:
  console.log(error)
  context.error({ statusCode: 304, message: 'Server error' })
}
